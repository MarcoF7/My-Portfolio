import re
import numpy as np
import pandas as pd
import torch
from transformers import BertTokenizer
from sklearn.preprocessing import LabelEncoder
from torch.utils.data import TensorDataset, DataLoader, RandomSampler, SequentialSampler
import torch.nn as nn
from transformers import BertModel
from transformers import AdamW, get_linear_schedule_with_warmup
import random
import time 
import nltk
from nltk.stem import WordNetLemmatizer
from nltk.tokenize import word_tokenize  
nltk.download('wordnet')
nltk.download('punkt')

import warnings
warnings.filterwarnings("ignore")

if torch.cuda.is_available():       
    device = torch.device("cuda")
    print(f'There are {torch.cuda.device_count()} GPU(s) available.')
    print('Device name:', torch.cuda.get_device_name(0))

else:
    print('No GPU available, using the CPU instead.')
    device = torch.device("cpu")
def set_seed(seed_value=42):
    # Define Random Seed
    random.seed(seed_value)
    np.random.seed(seed_value)
    torch.manual_seed(seed_value)
    torch.cuda.manual_seed_all(seed_value)


class BertClassifier(nn.Module):

    def __init__(self):
        """
        bert: a Bert Pretrained Model
        classifier: Linear classifier
        """
        super(BertClassifier, self).__init__()
        # D_in : Size of Output of Bert , D_out number of CLasses
        D_in, D_out = 768, 3

        # import BERT model
        self.bert = BertModel.from_pretrained('bert-base-uncased')

        # Instantiate Linear classifier
        self.classifier = nn.Sequential(
            nn.Linear(D_in, D_out),
            nn.ReLU()
            
        )

     
    def forward(self, input_ids, attention_mask):
   
       
        outputs = self.bert(input_ids=input_ids,
                            attention_mask=attention_mask)
        
        last_hidden_state_cls = outputs[0][:, 0, :]

        logits = self.classifier(last_hidden_state_cls)

        return logits
    
def initialize_model(train_dataloader,epochs=4):
    
   
    bert_classifier = BertClassifier()
    bert_classifier.to(device)
    optimizer = AdamW(bert_classifier.parameters(),
                      lr=1e-5 ,    
                      eps=1e-8    
                      )

   
    total_steps = len(train_dataloader) * epochs

   
    scheduler = get_linear_schedule_with_warmup(optimizer,
                                                num_warmup_steps=0,
                                                num_training_steps=total_steps)
    return bert_classifier, optimizer, scheduler


def train_classifier(model,optimizer,scheduler, train_dataloader, epochs=4):
    """Train the BertClassifier model.
    """
    # Start training loop
    print("Start training...\n")
    loss_fn = nn.CrossEntropyLoss()
    for epoch_i in range(epochs):

        print(f"{'Epoch':^7} | {'Batch':^7} | {'Train Loss':^12} | {'Elapsed':^9}")
        print("-"*50)

        
        t0_batch = time.time()

        # Running_loss
        batch_loss, batch_counts = 0, 0

        # Set Model to train mode
        model.train()

        
        for step, batch in enumerate(train_dataloader):
           
            batch_counts +=1
            
            b_input_ids, b_attn_mask, b_labels = tuple(t.to(device) for t in batch)

            model.zero_grad()

            # forward pass
            logits = model(b_input_ids, b_attn_mask)
            
            # Compute loss and Running loss 
            loss = loss_fn(logits, b_labels)
            batch_loss += loss.item()
           

            # backward pass 
            loss.backward()

            # Normalize gradient
            torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)

          
            optimizer.step()
            scheduler.step()
            if (step % 20 == 0 and step != 0) or (step == len(train_dataloader) - 1):
               
                time_elapsed = time.time() - t0_batch

                
                print(f"{epoch_i + 1:^7} | {step:^7} | {batch_loss / batch_counts:^12.6f} | {time_elapsed:^9.2f}")

            
                batch_loss, batch_counts = 0, 0
                t0_batch = time.time()
                
    print("Training complete!")

    
def evaluate(model, dataloader):
    # Set model to eval mode
 
    model.eval()
    pred = []
   
    for batch in dataloader:
       
        b_input_ids, b_attn_mask = tuple(t.to(device) for t in batch)      
        with torch.no_grad():
            logits = model(b_input_ids, b_attn_mask)       
            preds = torch.argmax(logits, dim=1).flatten()       
        pred.append(preds.item())
    return np.array(pred)


lemmatizer = WordNetLemmatizer()
stemmer = nltk.porter.PorterStemmer()


def text_preprocessing(s):
    
    s = re.sub(r'(@.*?)[\s]', ' ', s)
    s = re.sub(r'([\"\.\(\)\!\?\\\/\,])', r' \1 ', s)
    s = re.sub(r'([\;\:\|•«\n])', ' ', s)
    s = re.sub(r'\s+', ' ', s).strip()
    tokens = word_tokenize(s)
    s = ''
    for w in tokens:
      s += (((lemmatizer.lemmatize(w))))+ ' '
    return s

# Load BERT tokenizer
tokenizer = BertTokenizer.from_pretrained('bert-base-uncased', do_lower_case=True)

# Create a function to tokenize a set of texts
def preprocessing_input_bert(data):
    # Create empty lists to store outputs
    input_ids = []
    attention_masks = []

    # For every sentence...
    for s in data:
        encoded_sent = tokenizer.encode_plus(
            text=text_preprocessing(s),  # Preprocess sentence
            add_special_tokens=True,        # Add `[CLS]` and `[SEP]`
            max_length=150,                  # Max length to truncate/pad
            pad_to_max_length=True,         # Pad sentence to max length
            truncation=True ,              # truncate sentence
            return_attention_mask=True      # Return attention mask
            )
        
        # Add the outputs to the lists
        input_ids.append(encoded_sent.get('input_ids'))
        attention_masks.append(encoded_sent.get('attention_mask'))

    # Convert lists to tensors
    input_ids = torch.tensor(input_ids)
    attention_masks = torch.tensor(attention_masks)

    return input_ids, attention_masks


class Classifier:
    """The Classifier"""

    def train(self, trainfile):
        """Trains the classifier model on the training set stored in file trainfile"""

        # We load the data 
        data_train = pd.read_csv(trainfile, sep = "\t", names = ["polarity", "category", "word", "offsets", "sentence"])
        data_train.sentence = data_train.sentence.apply(str.lower)
        X_train = data_train.sentence
        self.LY = LabelEncoder()
        y_train = self.LY.fit_transform(data_train.polarity)
        train_inputs, train_masks = preprocessing_input_bert(X_train)
        train_labels = torch.tensor(y_train)
        
        batch_size = 32
        

        # Create the DataLoader for our training set
        train_data = TensorDataset(train_inputs, train_masks, train_labels)
        train_sampler = RandomSampler(train_data)
        train_dataloader = DataLoader(train_data, sampler=train_sampler, batch_size=batch_size)
        set_seed(42)    # Set seed for reproducibility
        self.bert_classifier, self.optimizer, self.scheduler = initialize_model(train_dataloader,epochs=4)
        
        train_classifier(self.bert_classifier,self.optimizer,self.scheduler, train_dataloader, epochs=4)
        


    def predict(self, datafile):
        """Predicts class labels for the input instances in file 'datafile'
        Returns the list of predicted labels
        """
 
        # We load the test data
        data_test = pd.read_csv(datafile, sep = "\t", names = ["polarity", "category", "word", "offsets", "sentence"])
        data_test.sentence = data_test.sentence.apply(str.lower)
        print('Tokenizing data...')
        test_inputs, test_masks = preprocessing_input_bert(data_test.sentence)
        

        # Create the DataLoader for our test set
        test_dataset = TensorDataset(test_inputs, test_masks)
        test_sampler = SequentialSampler(test_dataset)
        test_dataloader = DataLoader(test_dataset, sampler=test_sampler, batch_size=1)
        pred= evaluate(self.bert_classifier, test_dataloader)
        self.pred = self.LY.inverse_transform(pred)
        return self.pred