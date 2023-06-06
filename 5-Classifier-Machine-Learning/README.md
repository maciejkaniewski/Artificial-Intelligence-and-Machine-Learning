# Classifier Machine Learning

Classifier Machine Learning is a project I realized in the first semester of my Master's studies within the Artificial Intelligence and Machine Learning course at the Wroclaw University of Technology in the field of Control Engineering and Robotics.
The main goal of this task was to build a classifier for recognizing the theme of a short text (press note) in one of the following five groups: business, entertainment, politics, sport, tech.

## Table of Contents
- [Setup](#setup)
- [Usage](#usage)
- [Acknowledgements](#acknowledgements)

## Setup
The scripts were tested for `Python 3.10.6` version.

Create virtual environment:

```
python3 -m venv venv
```

Activate virtual environment:

```
source venv/bin/activate 
```

Install requirements:

```
pip3 install -r requirements.txt
```

## Usage

### Finding best model

In order to find the best model, `CrossValidation` and additionally `GridSearchCV` were used to optimize the hyperparameters for individual classifiers. The training of the model is based on the database provided by PhD Paluszyński, which can be found [here](https://kcir.pwr.edu.pl/~witold/ai/TextClass_text.tgz). Run the script with following command:

```
python3 find_the_best_model.py
```

Script output:

```
Best parameters for CountVectorizer -> Naive-Bayes pipeline: 
{'Count_Vectorizer__ngram_range': (1, 1), 'Count_Vectorizer__stop_words': 'english', 'Naive_Bayes__alpha': 0.1}
Best cross-validation score for CountVectorizer -> Naive-Bayes pipeline: 0.9780898876404495

Best parameters for TF-IDF -> Naive-Bayes pipeline: 
{'Naive_Bayes__alpha': 0.1, 'TF-IDF__ngram_range': (1, 1), 'TF-IDF__stop_words': 'english'}
Best cross-validation score for TF-IDF -> Naive-Bayes pipeline: 0.9792134831460675

Best parameters for CountVectorizer -> Decision_Tree pipeline: 
{'Count_Vectorizer__ngram_range': (1, 1), 'Count_Vectorizer__stop_words': 'english', 'Decision_Tree__max_depth': None}
Best cross-validation score for CountVectorizer -> Decision_Tree pipeline: 0.8348314606741573

Best parameters for TF-IDF -> Decision_Tree pipeline:
{'Decision_Tree__max_depth': None, 'TF-IDF__ngram_range': (1, 1), 'TF-IDF__stop_words': 'english'}
Best cross-validation score for TF-IDF -> Decision_Tree pipeline: 0.8235955056179776

Best parameters for CountVectorizer -> KNN pipeline:
{'Count_Vectorizer__ngram_range': (1, 1), 'Count_Vectorizer__stop_words': None, 'Nearest_Neighbors__n_neighbors': 3}
Best cross-validation score for CountVectorizer -> KNN pipeline: 0.7646067415730337

Best parameters for TF-IDF -> KNN pipeline:
{'Nearest_Neighbors__n_neighbors': 5, 'TF-IDF__ngram_range': (1, 2), 'TF-IDF__stop_words': 'english'}
Best cross-validation score for TF-IDF -> KNN pipeline: 0.9477528089887641

Best parameters for CountVectorizer -> SVM pipeline:
{'Count_Vectorizer__ngram_range': (1, 2), 'Count_Vectorizer__stop_words': 'english', 'SVM__C': 1, 'SVM__gamma': 'scale', 'SVM__kernel': 'linear'}
Best cross-validation score for CountVectorizer -> SVM pipeline: 0.9719101123595506

Best parameters for TF-IDF -> SVM pipeline:
{'SVM__C': 25, 'SVM__gamma': 'scale', 'SVM__kernel': 'sigmoid', 'TF-IDF__ngram_range': (1, 2), 'TF-IDF__stop_words': 'english'}
Best cross-validation score for TF-IDF -> SVM pipeline: 0.9837078651685391

Execution time: 8176.99s
```

The script returns the best model configurations for a given classifier and their cross validation score. Based on that score, we evaluate the best classifier and its hyperparameter configurations. Searching for the best parameters can take a long time. On a computer with the parameters presented below, it took `2 hrs 16 min 16 sec`.

```
Hardware Model: Micro-Star International Co., Ltd. GV62 8RE
Processor: Intel® Core™ i7-8750H CPU @ 2.20GHz × 12
Graphics: GeForce GTX 1060 Mobile
Memory: 16GB
```

### Saving the best model

Based on the results of the previous script, the model with the best cross validation score was defined. Run the script with following command:

```
python3 save_the_best_model.py
```

```python
model = Pipeline
([
    ('TF-IDF', TfidfVectorizer(ngram_range=(1, 2), stop_words='english')),
    ('SVM', SVC(C=25, gamma='scale', kernel='sigmoid'))
])
```
The model is saved to `trained_model.pkl` file.

### Creating test dataset

Directory `data` provided by PhD Paluszyński is a part of **BBC Dataset**, that can be found [here](http://mlg.ucd.ie/datasets/bbc.html). Script `create_test_dataset.py` removed the common text files for both datasets, leaving only new texts that can be used to test our model. There is no need to run said script since the test directory is ready to use.

### Test trained model

For the `test_trained_model.py` script, it is possible to specify the directory with the test dataset via the command line argument. By default, the script uses the current `test_dataset` directory.

```
usage: test_trained_model.py [-h] [-data_path DATA_PATH]

options:
  -h, --help            show this help message and exit
  -data_path DATA_PATH  Path to the test dataset
```

Example usage:

```
python3 test_trained_model.py -data test_dataset
```

The script returns classification report and displays confusion matrix.

```
Accuracy: 0.9798206278026906
Classification Report:
               precision    recall  f1-score   support

     business       0.97      0.97      0.97       102
entertainment       1.00      0.96      0.98        77
     politics       0.95      0.99      0.97        84
        sport       0.99      1.00      1.00       103
         tech       0.99      0.97      0.98        80

     accuracy                           0.98       446
    macro avg       0.98      0.98      0.98       446
 weighted avg       0.98      0.98      0.98       446

```

## Acknowledgements
- [Working With Text Data](https://scikit-learn.org/stable/tutorial/text_analytics/working_with_text_data.html)
