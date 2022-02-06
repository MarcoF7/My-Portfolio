from __future__ import division
import argparse
import pandas as pd
import pickle
# useful stuff
import struct
import numpy as np
from scipy.special import expit

__authors__ = ['Nabil Mouadden','Marco Antonio Guillermo Farfan Quiroz','Camille Friedrich','Noureddine Sedki']
__emails__  = ['nabil.mouadden@student-cs.fr','marco.farfan@student-cs.fr','camille.friedrich@student-cs.fr','noureddine.sedki@student-cs.fr']

def text2sentences(path):
	# feel free to make a better tokenization/pre-processing
	sentences = []
	with open(path, 'rb') as f:
		for l in f:
			sentences.append( l.lower().split() )
	return sentences

def loadPairs(path):
	data = pd.read_csv(path, delimiter='\t')
	pairs = zip(data['word1'],data['word2'],data['similarity'])
	return pairs


class SkipGram:
    def __init__(self, sentences=[], nEmbed=100, negativeRate=5, winSize = 5, minCount = 5):
        self.nEmbed = nEmbed
        self.negativeRate = negativeRate
        self.winSize = winSize
        self.minCount = minCount
        
        self.w2id = {}
        self.trainset = sentences
        self.vocab = [] # list of valid words
        self.corpus = []
        self.loss = []

        for sentence in self.trainset:
            for word in sentence:
                self.corpus.append(word)
                if word not in self.vocab:
                    self.vocab.append(word)
        self.w2id = {w: idx for (idx, w) in enumerate(self.vocab)}
        self.table= []
        # init hidden layer weights from the uniform distribution specified below
        self.w1 = np.random.uniform(low=-0.5/self.nEmbed, high=0.5/self.nEmbed, size=(len(self.vocab), self.nEmbed))

        # Init output layer weights with zeros
        self.w2 = np.zeros(shape=(len(self.vocab), self.nEmbed))

        self.trainWords = 0
        self.accLoss = 0

    def init_unigram (self):
        result = dict(zip(*np.unique(self.corpus, return_counts=True)))
        norm = sum(result.values())
        table_size = 100000000
        table = np.zeros(table_size, dtype=np.uint32)

        p = 0
        i = 0
        for j, unigram in enumerate(self.vocab):
            p += float(np.power(result[unigram], 0.75))/norm
            while i < table_size and float(i) / table_size < p:
                table[i] = j
                i += 1
        return table

    def sample(self, omit):
      #Initializing the unigram table from where the indexes will be sampled
      #Omit the element in "omit" set from unigram table that we will sample from
        nl=[] 
        while len(nl)<self.negativeRate:
          a=np.random.choice(self.table, 1)
          e=a[0]
          if e not in set(omit):
            nl.append(e)
        #(self.table).difference(set(omit))

        return nl
        

    def train(self, epochs=1, alpha=0.1):
      #We start by initializing our variables and defining our method constants
        wordCount=0
        lastWordCount = 0
        wordCountActual = 0
        self.table = self.init_unigram() #It should be put outside of training, but we didn't want to slow the testing phase
        s_lr = alpha
        lr = alpha
        i=0
        for iter in range(epochs): #we train the model for a defined number of epochs
          print("> training epoch %d" %iter)
          for counter, sentence in enumerate(self.trainset):
              sentence = list(filter(lambda word: word in self.vocab, sentence))
              for wpos, word in enumerate(sentence):
                  #if (wordCount - lastWordCount > 10000):
                  #   wordCountActual += wordCount - lastWordCount
                  #   lr = s_lr * (1 - float(wordCountActual) / (iter * len(self.vocab) + 1))
                  #   lastWordCount = wordCount
                  #   if (lr < s_lr * 0.0001): lr = s_lr * 0.0001
                  wIdx = self.w2id[word]
                  winsize = np.random.randint(self.winSize) + 1
                  start = max(0, wpos - winsize)
                  end = min(wpos + winsize + 1, len(sentence))

                  for context_word in sentence[start:end]:
                      ctxtId = self.w2id[context_word]
                      if ctxtId == wIdx: continue
                      negativeIds = self.sample({wIdx, ctxtId})
                      self.trainWord(wIdx, ctxtId, negativeIds, lr)
                      print("> training word %d     epoch: %d" %(self.trainWords, iter))
                      self.trainWords += 1
                  wordCount += 1

              if counter % 1000 == 0:
                  print("> training sentence %d of %d     epoch: %d" %(counter, len(self.trainset), iter))
                  self.loss.append(self.accLoss / self.trainWords)
                  self.trainWords = 0
                  self.accLoss = 0

    def trainWord(self, wordId, contextId, negativeIds, lr):
                    # Init error to propagate
                    err = np.zeros(self.nEmbed)

                    trainS = [(wordId, 1)] 
                    trainS += [(neg, 0) for neg in negativeIds]
  
                    for target, label in trainS:
                        f = np.dot(self.w1[contextId], self.w2[target])
                        # compute gradient after applying sigmoid to f
                        if (f > 6) : g = (label - 1) * lr
                        elif (f < -6) : g = (label - 0) * lr
                        else : g = (label - (1 / (1 + np.exp(-f)))) * lr

                        err += g * self.w2[target]              # compute Error to backpropagate to input layer
                        self.w2[target] += g * self.w1[contextId] # Update the weights of the output layer

                    # Update the weights of the input layer
                    self.w1[contextId] += err

    def save(self,path):
        saver = {'hidden': self.w1,
              'w2id': self.w2id,
              'decoder': self.w2,
              'dim': self.nEmbed
              }

        with open(path, 'wb') as f:
          pickle.dump(saver, f)

    def similarity(self,word1,word2):
        """
            computes similiarity between the two words. unknown words are mapped to one common vector
        :param word1:
        :param word2:
        :return: a float \in [0,1] indicating the similarity (the higher the more similar)
        """
        default_embd = np.ones(self.nEmbed)*0.01

        if word1 in self.vocab:
            idx_word1 = self.w2id[word1]
            embd_word1 = self.w1[idx_word1]
        else:
            return 0
            embd_word1 = default_embd

        if word2 in self.vocab:
            idx_word2 = self.w2id[word2]
            embd_word2 = self.w1[idx_word2]
        else:
            return 0
            embd_word2 = default_embd

        dot_product = np.dot(embd_word1, embd_word2)
        norm_a = np.linalg.norm(embd_word1)
        norm_b = np.linalg.norm(embd_word2)

        return ((dot_product / (norm_a * norm_b)) + 1)/2

    @staticmethod
    def load(path):
        model = SkipGram()
        with open(path, 'rb') as f:
          saved = pickle.load(f)
        print(saved)
        model.w1 = saved['hidden']
        model.w2id = saved['w2id']
        model.w2 = saved['decoder']
        model.nEmbed = saved['dim']
        model.vocab = set(model.w2id.keys())
        return model
        
if __name__ == '__main__':

	parser = argparse.ArgumentParser()
	parser.add_argument('--text', help='path containing training data', required=True)
	parser.add_argument('--model', help='path to store/read model (when training/testing)', required=True)
	parser.add_argument('--test', help='enters test mode', action='store_true')

	opts = parser.parse_args()

	if not opts.test:
		sentences = text2sentences(opts.text)
		sg = SkipGram(sentences)
		sg.train()
		sg.save(opts.model)

	else:
		pairs = loadPairs(opts.text)

		sg = SkipGram.load(opts.model)
		for a,b,_ in pairs:		
			print(sg.similarity(a,b))