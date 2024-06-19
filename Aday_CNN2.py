# https://realpython.com/python-keras-text-classification/
    
import pandas as pd
import glob
import os
from sklearn.feature_extraction.text import CountVectorizer
from tqdm import tqdm



# Specify the path to your CSV files
path = os.getcwd()
all_files = glob.glob(os.path.join(path, "*.csv"))

# Read each CSV file and store in a list
dfs = []
for filename in all_files:
    df = pd.read_csv(filename, index_col=None, header=0, encoding="utf-8")  # Assuming the first row contains column names
    dfs.append(df)

# Concatenate all dataframes into one
big_frame = pd.concat(dfs, ignore_index=True)

# Now `big_frame` contains the combined data from all CSV files
# print(big_frame.head())  # You can modify this line to suit your needs

sentences = big_frame[u'Text'].values
labels = big_frame[u'Header'].values

from sklearn.model_selection import train_test_split
# https://scikit-learn.org/stable/modules/generated/sklearn.model_selection.train_test_split.html
sentences_train, sentences_test, y_train, y_test = train_test_split(sentences, labels, test_size=0.20, random_state=1000)

from sklearn.feature_extraction.text import CountVectorizer
# https://scikit-learn.org/stable/modules/generated/sklearn.feature_extraction.text.CountVectorizer.html
vect = CountVectorizer(analyzer='word')
vect.fit(sentences_train)

X_train = vect.transform(sentences_train)
X_test  = vect.transform(sentences_test)

from sklearn.linear_model import LogisticRegression
# https://scikit-learn.org/stable/modules/generated/sklearn.linear_model.LogisticRegression.html

classifier = LogisticRegression(verbose=False, penalty='l2', solver='newton-cholesky')
classifier.fit(X_train, y_train)
score = classifier.score(X_test, y_test)

print("Accuracy:", score)


#vect.vocabulary_
#vect.transform(big_frame['Text'])
#print(vect)



'''
for sentence in big_frame['Text']:
    train = vect.fit_transform([sentence])
    print(train)
'''