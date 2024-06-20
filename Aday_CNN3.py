import pandas as pd
import glob
import os
import numpy as np

# Fix for protobuf not being recognized
#export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION="upb"
#os.environ["PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION"] = "upb"

from sklearn.model_selection import train_test_split

from tensorflow.keras import Sequential
from tensorflow.keras import layers
from keras.backend import clear_session

from keras.backend import clear_session
clear_session()

# Specify the path to your CSV files
path = os.getcwd()
all_files = glob.glob(os.path.join(path, "*.csv"))

# Read each CSV file and store in a list
dfs = []
for filename in all_files:
    df = pd.read_csv(filename, index_col=None, header=0, encoding="utf-8", engine="python")  # Assuming the first row contains column names
    dfs.append(df)

# Concatenate all dataframes into one
big_frame = pd.concat(dfs, ignore_index=True).dropna()
big_frame = pd.get_dummies(big_frame[["Text", "Header"]], columns=["Header"])

print(big_frame.head())
#print(big_frame.dtypes)
# Now `big_frame` contains the combined data from all CSV files
# print(big_frame.head())  # You can modify this line to suit your needs

sentences = big_frame[u'Text'].values
labels = big_frame[u'Header']

from sklearn.preprocessing import LabelEncoder
label_encoder = LabelEncoder()
Y = label_encoder.fit_transform(labels)
sentences_train, sentences_test, y_train, y_test = train_test_split(sentences, Y, test_size=0.25, random_state=1000, stratify=Y,shuffle=True)
#print(sentences_train)

from sklearn.utils.class_weight import compute_class_weight
classWeight = compute_class_weight(class_weight="balanced", classes=np.unique(Y), y=Y)
classWeight = dict(enumerate(classWeight))
#print(classWeight)

'''
from sklearn.feature_extraction.text import CountVectorizer
vect = CountVectorizer(analyzer='word')
vect.fit(sentences_train)

X_train = vect.transform(sentences_train)
X_test  = vect.transform(sentences_test)
'''
from tensorflow.keras.preprocessing.text import Tokenizer
tokenizer = Tokenizer(num_words=5000, char_level=True)
tokenizer = Tokenizer(num_words=5000, char_level=True)
tokenizer.fit_on_texts(sentences_train.astype(str))
tokenizer.fit_on_texts(sentences_test.astype(str))

X_train = tokenizer.texts_to_sequences(sentences_train)
X_test = tokenizer.texts_to_sequences(sentences_test)

vocab_size = len(tokenizer.word_index) + 1  # Adding 1 because of reserved 0 index

# print(sentences_train[2])
# print(X_train[2])

from tensorflow.keras.preprocessing.sequence import pad_sequences

maxlen = 100
X_train = pad_sequences(X_train, padding='post', maxlen=maxlen)
X_test = pad_sequences(X_test, padding='post', maxlen=maxlen)

#print(type(X_train[0, :]))


embedding_dim = 100

model = Sequential()
model.add(layers.Embedding(input_dim=vocab_size, output_dim=embedding_dim, input_length=maxlen, trainable=True))
#model.add(layers.Flatten())
model.add(layers.GlobalMaxPool1D())
model.add(layers.Dense(10, activation='relu'))
model.add(layers.Dense(1, activation='softmax'))
#model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])

from tensorflow.keras.optimizers import SGD
#opt = SGD(lr=0.0000001)
model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])
model.summary()

'''
input_dim = X_train.shape[1]  # Number of features
model = Sequential()
model.add(layers.Dense(10, input_dim=input_dim, activation='relu'))
model.add(layers.Dense(1, activation='sigmoid'))
model.compile(loss='binary_crossentropy',  optimizer='adam', metrics=['accuracy'])
model.summary()
#print(type(X_train))
#print(y_train)
'''

#from keras.backend import clear_session
#clear_session()
history = model.fit(X_train, y_train, epochs=50, verbose=True, validation_data=(X_test, y_test),batch_size=10, class_weight=classWeight)
#history = model.fit(X_train, y_train, epochs=50, verbose=True, validation_data=(X_test, y_test),batch_size=100)

#print(history.history.keys()) # Check to see whether the plot_history function is referring to the correct keys

loss, accuracy = model.evaluate(X_train, y_train, verbose=True)
#results = model.evaluate(X_train, y_train, verbose=True)
#print(results)
print("Training Accuracy: {:.4f}".format(accuracy))
loss, accuracy = model.evaluate(X_test, y_test, verbose=False)
print("Testing Accuracy:  {:.4f}".format(accuracy))

import matplotlib.pyplot as plt
plt.style.use('ggplot')

def plot_history(history):
    acc = history.history['accuracy']
    val_acc = history.history['val_accuracy']
    loss = history.history['loss']
    val_loss = history.history['val_loss']
    x = range(1, len(acc) + 1)

    plt.figure(figsize=(12, 5))
    plt.subplot(1, 2, 1)
    plt.plot(x, acc, 'b', label='Training acc')
    plt.plot(x, val_acc, 'r', label='Validation acc')
    plt.title('Training and validation accuracy')
    plt.legend()
    plt.subplot(1, 2, 2)
    plt.plot(x, loss, 'b', label='Training loss')
    plt.plot(x, val_loss, 'r', label='Validation loss')
    plt.title('Training and validation loss')
    plt.legend()
    plt.show()

plot_history(history)
