import torch
import numpy as np
import pandas as pd
import re, os, string, typing, gc, json, unicodedata, time
import spacy
from collections import Counter
import torchtext
from torch import nn
import torch.nn.functional as F
import spacy
from collections import Counter
from nltk import word_tokenize
from utilis import *
nlp = spacy.load('en')

class DocumentReader(nn.Module):
    
    def __init__(self, hidden_dim, embedding_dim, num_layers, num_directions, dropout, device, glove_dict, word_vocab):
        
        super().__init__()
        
        self.device = device
        
        self.context_bilstm = StackedBRNN(embedding_dim * 2, hidden_dim, num_layers, dropout)
        
        self.question_bilstm = StackedBRNN(embedding_dim, hidden_dim, num_layers, dropout)
        
        self.glove_embedding = self.get_glove_embedding(glove_dict, word_vocab)
        
        def tune_embedding(grad, words=1000):
            grad[words:] = 0
            return grad
        
        self.glove_embedding.weight.register_hook(tune_embedding)
        
        self.align_embedding = AlignQuestionEmbedding(embedding_dim)
        
        self.linear_attn_question = LinearAttentionLayer(hidden_dim*num_layers*num_directions) 
        
        self.bilinear_attn_start = BilinearAttentionLayer(hidden_dim*num_layers*num_directions, 
                                                          hidden_dim*num_layers*num_directions)
        
        self.bilinear_attn_end = BilinearAttentionLayer(hidden_dim*num_layers*num_directions,
                                                        hidden_dim*num_layers*num_directions)
        
        self.dropout = nn.Dropout(dropout)
   
        
    def get_glove_embedding(self, glove_dict, word_vocab):
        
        weights_matrix, _ = create_word_embedding(glove_dict, word_vocab)
        #num_embeddings, embedding_dim = weights_matrix.shape
        embedding = nn.Embedding.from_pretrained(torch.FloatTensor(weights_matrix).to(self.device),freeze=False)

        return embedding
    
    
    def forward(self, context, question, context_mask, question_mask):
       
        # context = [bs, len_c]
        # question = [bs, len_q]
        # context_mask = [bs, len_c]
        # question_mask = [bs, len_q]
        
        
        ctx_embed = self.glove_embedding(context)
        # ctx_embed = [bs, len_c, emb_dim]
        
        ques_embed = self.glove_embedding(question)
        # ques_embed = [bs, len_q, emb_dim]
        

        ctx_embed = self.dropout(ctx_embed)
     
        ques_embed = self.dropout(ques_embed)
             
        align_embed = self.align_embedding(ctx_embed, ques_embed, question_mask)
        # align_embed = [bs, len_c, emb_dim]  
        
        ctx_bilstm_input = torch.cat([ctx_embed, align_embed], dim=2)
        # ctx_bilstm_input = [bs, len_c, emb_dim*2]
                
        ctx_outputs = self.context_bilstm(ctx_bilstm_input)
        # ctx_outputs = [bs, len_c, hid_dim*layers*dir] = [bs, len_c, hid_dim*6]
       
        qtn_outputs = self.question_bilstm(ques_embed)
        # qtn_outputs = [bs, len_q, hid_dim*6]
    
        qtn_weights = self.linear_attn_question(qtn_outputs, question_mask)
        # qtn_weights = [bs, len_q]
            
        qtn_weighted = weighted_average(qtn_outputs, qtn_weights)
        # qtn_weighted = [bs, hid_dim*6]
        
        start_scores = self.bilinear_attn_start(ctx_outputs, qtn_weighted, context_mask)
        # start_scores = [bs, len_c]
         
        end_scores = self.bilinear_attn_end(ctx_outputs, qtn_weighted, context_mask)
        # end_scores = [bs, len_c]
        
      
        return start_scores, end_scores

class AlignQuestionEmbedding(nn.Module):
    
    def __init__(self, input_dim):        
        
        super().__init__()
        
        self.linear = nn.Linear(input_dim, input_dim)
        
        self.relu = nn.ReLU()
        
    def forward(self, context, question, question_mask):
        
        # context = [bs, ctx_len, emb_dim]
        # question = [bs, qtn_len, emb_dim]
        # question_mask = [bs, qtn_len]
    
        ctx_ = self.linear(context)
        ctx_ = self.relu(ctx_)
        # ctx_ = [bs, ctx_len, emb_dim]
        
        qtn_ = self.linear(question)
        qtn_ = self.relu(qtn_)
        # qtn_ = [bs, qtn_len, emb_dim]
        
        qtn_transpose = qtn_.permute(0,2,1)
        # qtn_transpose = [bs, emb_dim, qtn_len]
        
        align_scores = torch.bmm(ctx_, qtn_transpose)
        # align_scores = [bs, ctx_len, qtn_len]
        
        qtn_mask = question_mask.unsqueeze(1).expand(align_scores.size())
        # qtn_mask = [bs, 1, qtn_len] => [bs, ctx_len, qtn_len]
        
        # Fills elements of self tensor(align_scores) with value(-float(inf)) where mask is True. 
        # The shape of mask must be broadcastable with the shape of the underlying tensor.
        align_scores = align_scores.masked_fill(qtn_mask == 1, -float('inf'))
        # align_scores = [bs, ctx_len, qtn_len]
        
        align_scores_flat = align_scores.view(-1, question.size(1))
        # align_scores = [bs*ctx_len, qtn_len]
        
        alpha = F.softmax(align_scores_flat, dim=1)
        alpha = alpha.view(-1, context.shape[1], question.shape[1])
        # alpha = [bs, ctx_len, qtn_len]
        
        align_embedding = torch.bmm(alpha, question)
        # align = [bs, ctx_len, emb_dim]
        
        return align_embedding

class StackedBRNN(nn.Module):
    
    def __init__(self, input_dim, hidden_dim, num_layers, dropout):
        
        super().__init__()
        
        self.dropout = dropout
        
        self.num_layers = num_layers
        
        self.lstms = nn.ModuleList()
        
        for i in range(self.num_layers):
            
            input_dim = input_dim if i == 0 else hidden_dim * 2
            
            self.lstms.append(nn.LSTM(input_dim, hidden_dim,
                                      batch_first=True, bidirectional=True))
           
    
    def forward(self, x):
        # x = [bs, seq_len, feature_dim]

        outputs = [x]
        for i in range(self.num_layers):

            lstm_input = outputs[-1]
            lstm_out = F.dropout(lstm_input, p=self.dropout)
            lstm_out, (hidden, cell) = self.lstms[i](lstm_input)
           
            outputs.append(lstm_out)

    
        output = torch.cat(outputs[1:], dim=2)
        # [bs, seq_len, num_layers*num_dir*hidden_dim]
        
        output = F.dropout(output, p=self.dropout)
      
        return output
        
class LinearAttentionLayer(nn.Module):
    
    def __init__(self, input_dim):
        
        super().__init__()
        
        self.linear = nn.Linear(input_dim, 1)
        
    def forward(self, question, question_mask):
        
        # question = [bs, qtn_len, input_dim] = [bs, qtn_len, bi_lstm_hid_dim]
        # question_mask = [bs,  qtn_len]
        
        qtn = question.view(-1, question.shape[-1])
        # qtn = [bs*qtn_len, hid_dim]
        
        attn_scores = self.linear(qtn)
        # attn_scores = [bs*qtn_len, 1]
        
        attn_scores = attn_scores.view(question.shape[0], question.shape[1])
        # attn_scores = [bs, qtn_len]
        
        attn_scores = attn_scores.masked_fill(question_mask == 1, -float('inf'))
        
        alpha = F.softmax(attn_scores, dim=1)
        # alpha = [bs, qtn_len]
        
        return alpha

class BilinearAttentionLayer(nn.Module):
    
    def __init__(self, context_dim, question_dim):
        
        super().__init__()
        
        self.linear = nn.Linear(question_dim, context_dim)
        
    def forward(self, context, question, context_mask):
        
        # context = [bs, ctx_len, ctx_hid_dim] = [bs, ctx_len, hid_dim*6] = [bs, ctx_len, 768]
        # question = [bs, qtn_hid_dim] = [bs, qtn_len, 768]
        # context_mask = [bs, ctx_len]
        
        qtn_proj = self.linear(question)
        # qtn_proj = [bs, ctx_hid_dim]
        
        qtn_proj = qtn_proj.unsqueeze(2)
        # qtn_proj = [bs, ctx_hid_dim, 1]
        
        scores = context.bmm(qtn_proj)
        # scores = [bs, ctx_len, 1]
        
        scores = scores.squeeze(2)
        # scores = [bs, ctx_len]
        
        scores = scores.masked_fill(context_mask == 1, -float('inf'))
        
        #alpha = F.log_softmax(scores, dim=1)
        # alpha = [bs, ctx_len]
        
        return scores

def train(model, train_dataset, device, optimizer):
    '''
    Trains the model.
    '''
    
    print("Starting training ........")
    
    train_loss = 0.
    batch_count = 0
    
    # put the model in training mode
    model.train()
    
    # iterate through training data
    for batch in train_dataset:

        if batch_count % 500 == 0:
            print(f"Starting batch: {batch_count}")
        batch_count += 1

        context, question, context_mask, question_mask, label, ctx, ans, ids = batch
        
        # place the tensors on GPU
        context, context_mask, question, question_mask, label = context.to(device), context_mask.to(device),\
                                    question.to(device), question_mask.to(device), label.to(device)
        
        # forward pass, get the predictions
        preds = model(context, question, context_mask, question_mask)

        start_pred, end_pred = preds
        
        # separate labels for start and end position
        start_label, end_label = label[:,0], label[:,1]
        
        # calculate loss
        loss = F.cross_entropy(start_pred, start_label) + F.cross_entropy(end_pred, end_label)
        
        # backward pass, calculates the gradients
        loss.backward()
        
        # gradient clipping
        torch.nn.utils.clip_grad_norm_(model.parameters(), 10)
        
        # update the gradients
        optimizer.step()
        
        # zero the gradients to prevent them from accumulating
        optimizer.zero_grad()

        train_loss += loss.item()

    return train_loss/len(train_dataset)

def valid(model, valid_dataset, device, idx2word):
    '''
    Performs validation.
    '''
    
    print("Starting validation .........")
   
    valid_loss = 0.

    batch_count = 0
    
    f1, em = 0., 0.
    
    # puts the model in eval mode. Turns off dropout
    model.eval()
    
    predictions = {}
    
    for batch in valid_dataset:

        if batch_count % 500 == 0:
            print(f"Starting batch {batch_count}")
        batch_count += 1

        context, question, context_mask, question_mask, label, context_text, answers, ids = batch

        context, context_mask, question, question_mask, label = context.to(device), context_mask.to(device),\
                                    question.to(device), question_mask.to(device), label.to(device)

        with torch.no_grad():

            preds = model(context, question, context_mask, question_mask)

            p1, p2 = preds

            y1, y2 = label[:,0], label[:,1]

            loss = F.cross_entropy(p1, y1) + F.cross_entropy(p2, y2)

            valid_loss += loss.item()

            
            # get the start and end index positions from the model preds
            
            batch_size, c_len = p1.size()
            ls = nn.LogSoftmax(dim=1)
            mask = (torch.ones(c_len, c_len) * float('-inf')).to(device).tril(-1).unsqueeze(0).expand(batch_size, -1, -1)
            
            score = (ls(p1).unsqueeze(2) + ls(p2).unsqueeze(1)) + mask
            score, s_idx = score.max(dim=1)
            score, e_idx = score.max(dim=1)
            s_idx = torch.gather(s_idx, 1, e_idx.view(-1, 1)).squeeze()
            
            # stack predictions
            for i in range(batch_size):
                id = ids[i]
                pred = context[i][s_idx[i]:e_idx[i]+1]
                pred = ' '.join([idx2word[idx.item()] for idx in pred])
                predictions[id] = pred
            
            
            
    em, f1 = evaluate(predictions)            
    return valid_loss/len(valid_dataset), em, f1

def evaluate(predictions):
    '''
    Gets a dictionary of predictions with question_id as key
    and prediction as value. The validation dataset has multiple 
    answers for a single question. Hence we compare our prediction
    with all the answers and choose the one that gives us
    the maximum metric (em or f1). 
    This method first parses the JSON file, gets all the answers
    for a given id and then passes the list of answers and the 
    predictions to calculate em, f1.
    
    
    :param dict predictions
    Returns
    : exact_match: 1 if the prediction and ground truth 
      match exactly, 0 otherwise.
    : f1_score: 
    '''
    with open('./SQuAD/dev-v1.1.json','r',encoding='utf-8') as f:
        dataset = json.load(f)
        
    dataset = dataset['data']
    f1 = exact_match = total = 0
    for article in dataset:
        for paragraph in article['paragraphs']:
            for qa in paragraph['qas']:
                total += 1
                if qa['id'] not in predictions:
                    continue
                
                ground_truths = list(map(lambda x: x['text'], qa['answers']))
                
                prediction = predictions[qa['id']]
                
                exact_match += metric_max_over_ground_truths(
                    exact_match_score, prediction, ground_truths)
                
                f1 += metric_max_over_ground_truths(
                    f1_score, prediction, ground_truths)
                
    
    exact_match = 100.0 * exact_match / total
    f1 = 100.0 * f1 / total
    
    return exact_match, f1

def normalize_answer(s):
    '''
    Performs a series of cleaning steps on the ground truth and 
    predicted answer.
    '''
    def remove_articles(text):
        return re.sub(r'\b(a|an|the)\b', ' ', text)

    def white_space_fix(text):
        return ' '.join(text.split())

    def remove_punc(text):
        exclude = set(string.punctuation)
        return ''.join(ch for ch in text if ch not in exclude)

    def lower(text):
        return text.lower()

    return white_space_fix(remove_articles(remove_punc(lower(s))))


def metric_max_over_ground_truths(metric_fn, prediction, ground_truths):
    '''
    Returns maximum value of metrics for predicition by model against
    multiple ground truths.
    
    :param func metric_fn: can be 'exact_match_score' or 'f1_score'
    :param str prediction: predicted answer span by the model
    :param list ground_truths: list of ground truths against which
                               metrics are calculated. Maximum values of 
                               metrics are chosen.
                            
    
    '''
    scores_for_ground_truths = []
    for ground_truth in ground_truths:
        score = metric_fn(prediction, ground_truth)
        scores_for_ground_truths.append(score)
        
    return max(scores_for_ground_truths)


def f1_score(prediction, ground_truth):
    '''
    Returns f1 score of two strings.
    '''
    prediction_tokens = normalize_answer(prediction).split()
    ground_truth_tokens = normalize_answer(ground_truth).split()
    common = Counter(prediction_tokens) & Counter(ground_truth_tokens)
    num_same = sum(common.values())
    if num_same == 0:
        return 0
    precision = 1.0 * num_same / len(prediction_tokens)
    recall = 1.0 * num_same / len(ground_truth_tokens)
    f1 = (2 * precision * recall) / (precision + recall)
    return f1


def exact_match_score(prediction, ground_truth):
    '''
    Returns exact_match_score of two strings.
    '''
    return (normalize_answer(prediction) == normalize_answer(ground_truth))


def epoch_time(start_time, end_time):
    '''
    Helper function to record epoch time.
    '''
    elapsed_time = end_time - start_time
    elapsed_mins = int(elapsed_time / 60)
    elapsed_secs = int(elapsed_time - (elapsed_mins * 60))
    return elapsed_mins, elapsed_secs