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