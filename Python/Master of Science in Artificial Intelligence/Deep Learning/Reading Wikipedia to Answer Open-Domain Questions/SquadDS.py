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
nlp = spacy.load('en')

class SquadDataset:
    
    def __init__(self, data, batch_size):
        
        self.batch_size = batch_size
        data = [data[i:i+self.batch_size] for i in range(0, len(data), self.batch_size)]
        self.data = data
    
    def get_span(self, text):
        
        text = nlp(text, disable=['parser','tagger','ner'])
        span = [(w.idx, w.idx+len(w.text)) for w in text]

        return span

    def __len__(self):
        return len(self.data)
    
    def __iter__(self):
        
        for batch in self.data:
                            
            spans = []
            context_text = []
            answer_text = []
            
            max_context_len = max([len(ctx) for ctx in batch.context_ids])
            padded_context = torch.LongTensor(len(batch), max_context_len).fill_(1)
            
            for ctx in batch.context:
                context_text.append(ctx)
                spans.append(self.get_span(ctx))
            
            for ans in batch.answer:
                answer_text.append(ans)
                
            for i, ctx in enumerate(batch.context_ids):
                padded_context[i, :len(ctx)] = torch.LongTensor(ctx)
            
            max_question_len = max([len(ques) for ques in batch.question_ids])
            padded_question = torch.LongTensor(len(batch), max_question_len).fill_(1)
            
            for i, ques in enumerate(batch.question_ids):
                padded_question[i,: len(ques)] = torch.LongTensor(ques)
                
            
            label = torch.LongTensor(list(batch.label_idx))
            context_mask = torch.eq(padded_context, 1)
            question_mask = torch.eq(padded_question, 1)
            
            ids = list(batch.id)  
            
            yield (padded_context, padded_question, context_mask, 
                   question_mask, label, context_text, answer_text, ids)
            
            