Natural Language Processing - Aspect Based Sentiment Analysis

I)	Authors :	Camille Friedrich
				Marco Antonio Guillermo Farfan Quiroz
				Nabil Mouadden
				Noureddine Sedki

II)	To run the code :

	python tester.py

III) Description of the proposed approach :

	In order to tackle the problem of Aspect Based Sentiment Analysis, we use the following strategy:

	1)	We first preprocess the input sentences by removing special characters and performing lemmatization on their words(we used the WordNetLemmatizer provided by the ntlk library).
	2)	As a next step, and since we are using a classifier based on a pretrained Bert transformer, we used a pretrained BertTokenizer to encode the sentences.
		This step enabled us to retrieve the input_ids that represent tokens and the attention_masks, the latter are binary tensors indicating the padded indices' position so that the model does not attend to them. We use padding to make all tokens the same size to put them in the same tensors.
		The inputs_ids and attention_masks will be the inputs of our BERT transformer.
	3)	We wrap our data (input_ids, mask, label) as a tensor and define a random sampler for sampling data during training before instantiating the training data loader.
	4)	Our classifier is built on a pretrained BertModel transformer:
			'bert-base-uncased': 12-layer, 768-hidden, 12-heads, 110M parameters.
			This model is pretrained on a large corpus of English data in a self-supervised fashion.
			This model aims to be fine-tuned on tasks that use the whole sentence (potentially masked) to make decisions, such as sequence classification, token classification, or question answering.
		On top of the pretrained BERT base model, we added a head composed of a linear layer followed by a ReLU activation function. The head acts as a classifier mapping the token hidden state, outputted by the Bert transformer to the three classes. The final output is a tensor of size 3.
	5)	To fine-tune the best-classifier, we used AdamW from the transformers library with a learning rate of 1e-5 and a batch size of 32. The training lasts four epochs.
	6)	Finally, we apply a softmax to retrieve the corresponding class.

IV)	Accuracy on the Dev Set: 85.64%

V)	Experiments:

	1)	We tried to use the aspect category as input for the final classifier, but the performance we got was below using only sentences.
	2)	Using TF-IDF and word count tokenizer alongside SVM, we have a performance of 78%.
	3)	We also tried to use the DistilBERT base model. A transformer model smaller and faster than BERT, which was pretrained on the same corpus in a self-supervised fashion, using the BERT base model as a teacher.
		The training and inference were much faster; however, the performance was not on par with the regular BERT (82.12%).