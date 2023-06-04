from sklearn.datasets import load_files
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import Pipeline
from sklearn.model_selection import GridSearchCV
from sklearn.tree import DecisionTreeClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from timeit import default_timer as timer

if __name__ == "__main__":
    start = timer()
    data = load_files("data", encoding="latin-1")

    param_grid_naive_bayes_cv = {
        'Count_Vectorizer__stop_words': ['english', None],
        'Count_Vectorizer__ngram_range': [(1, 1), (1, 2), (2, 2)],
        'Naive_Bayes__alpha': [0.1, 0.4, 0.7, 1.0]
    }

    grid_search_naive_bayes_cv = GridSearchCV(
        estimator=Pipeline([
            ('Count_Vectorizer', CountVectorizer()),
            ('Naive_Bayes', MultinomialNB())
        ]),
        param_grid=param_grid_naive_bayes_cv,
        cv=10, n_jobs=-1
    )

    param_grid_naive_bayes_tfidf = {
        'TF-IDF__stop_words': ['english', None],
        'TF-IDF__ngram_range': [(1, 1), (1, 2), (2, 2)],
        'Naive_Bayes__alpha': [0.1, 0.4, 0.7, 1.0]
    }

    grid_search_naive_bayes_tfidf = GridSearchCV(
        estimator=Pipeline([
            ('TF-IDF', TfidfVectorizer()),
            ('Naive_Bayes', MultinomialNB())
        ]),
        param_grid=param_grid_naive_bayes_tfidf,
        cv=10, n_jobs=-1
    )

    param_grid_decision_tree_cv = {
        'Count_Vectorizer__stop_words': ['english', None],
        'Count_Vectorizer__ngram_range': [(1, 1), (1, 2), (2, 2)],
        'Decision_Tree__max_depth': [None, 5, 10]
    }

    grid_search_decision_tree_cv = GridSearchCV(
        estimator=Pipeline([
            ('Count_Vectorizer', CountVectorizer()),
            ('Decision_Tree', DecisionTreeClassifier())
        ]),
        param_grid=param_grid_decision_tree_cv,
        cv=10, n_jobs=-1
    )

    param_grid_decision_tree_tfidf = {
        'TF-IDF__stop_words': ['english', None],
        'TF-IDF__ngram_range': [(1, 1), (1, 2), (2, 2)],
        'Decision_Tree__max_depth': [None, 5, 10]
    }

    grid_search_decision_tree_tfidf = GridSearchCV(
        estimator=Pipeline([
            ('TF-IDF', TfidfVectorizer()),
            ('Decision_Tree', DecisionTreeClassifier())
        ]),
        param_grid=param_grid_decision_tree_tfidf,
        cv=10, n_jobs=-1
    )

    param_grid_knn_cv = {
        'Count_Vectorizer__stop_words': ['english', None],
        'Count_Vectorizer__ngram_range': [(1, 1), (1, 2), (2, 2)],
        'Nearest_Neighbors__n_neighbors': [3, 5, 7]
    }

    grid_search_knn_cv = GridSearchCV(
        estimator=Pipeline([
            ('Count_Vectorizer', CountVectorizer()),
            ('Nearest_Neighbors', KNeighborsClassifier())
        ]),
        param_grid=param_grid_knn_cv,
        cv=10, n_jobs=-1
    )

    param_grid_knn_tfidf = {
        'TF-IDF__stop_words': ['english', None],
        'TF-IDF__ngram_range': [(1, 1), (1, 2), (2, 2)],
        'Nearest_Neighbors__n_neighbors': [3, 5, 7]
    }

    grid_search_knn_tfidf = GridSearchCV(
        estimator=Pipeline([
            ('TF-IDF', TfidfVectorizer()),
            ('Nearest_Neighbors', KNeighborsClassifier())
        ]),
        param_grid=param_grid_knn_tfidf,
        cv=10, n_jobs=-1
    )

    param_grid_svm_cv = {
        'Count_Vectorizer__stop_words': ['english', None],
        'Count_Vectorizer__ngram_range': [(1, 1), (1, 2), (2, 2)],
        'SVM__C': [1, 25, 50, 100],
        'SVM__kernel': ['linear', 'poly', 'rbf', 'sigmoid'],
        'SVM__gamma': ['scale', 'auto']
    }

    grid_search_svm_cv = GridSearchCV(
        estimator=Pipeline([
            ('Count_Vectorizer', CountVectorizer()),
            ('SVM', SVC())
        ]),
        param_grid=param_grid_svm_cv,
        cv=10, n_jobs=-1
    )

    param_grid_svm_tfidf = {
        'TF-IDF__stop_words': ['english', None],
        'TF-IDF__ngram_range': [(1, 1), (1, 2), (2, 2)],
        'SVM__C': [1, 25, 50, 100],
        'SVM__kernel': ['linear', 'poly', 'rbf', 'sigmoid'],
        'SVM__gamma': ['scale', 'auto']
    }

    grid_search_svm_tfidf = GridSearchCV(
        estimator=Pipeline([
            ('TF-IDF', TfidfVectorizer()),
            ('SVM', SVC())
        ]),
        param_grid=param_grid_svm_tfidf,
        cv=10, n_jobs=-1
    )

    best_params_scores = []

    for grid_search, pipeline_name in zip(
            [grid_search_naive_bayes_cv, grid_search_naive_bayes_tfidf,
             grid_search_decision_tree_cv, grid_search_decision_tree_tfidf,
             grid_search_knn_cv, grid_search_knn_tfidf,
             grid_search_svm_cv, grid_search_svm_tfidf],
            ['CountVectorizer -> Naive-Bayes', 'TF-IDF -> Naive-Bayes',
             'CountVectorizer -> Decision_Tree', 'TF-IDF -> Decision_Tree',
             'CountVectorizer -> KNN', 'TF-IDF -> KNN',
             'CountVectorizer -> SVM', 'TF-IDF -> SVM']
    ):
        print(pipeline_name)
        grid_search.fit(data.data, data.target)
        best_params = grid_search.best_params_
        best_score = grid_search.best_score_
        best_params_scores.append((pipeline_name, best_params, best_score))

    print()
    # Print the best parameters and scores for each pipeline
    for pipeline_name, best_params, best_score in best_params_scores:
        print(f"Best parameters for {pipeline_name} pipeline: {best_params}")
        print(f"Best cross-validation score for {pipeline_name} pipeline: {best_score}")
        print()
    end = timer()
    print(f"Execution time: {round(end - start, 2)}s")
