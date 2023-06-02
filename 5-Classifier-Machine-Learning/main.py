from sklearn.datasets import load_files
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import Pipeline
from sklearn.model_selection import GridSearchCV
from sklearn.tree import DecisionTreeClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from tabulate import tabulate

if __name__ == "__main__":

    data = load_files("data", encoding="latin-1")

    param_grid_naive_bayes_cv = {
        'Count_Vectorizer__stop_words': ['english', None],
        'Count_Vectorizer__ngram_range': [(1, 1), (1, 2), (2, 2)],
        'Naive_Bayes__alpha': [0.1, 1.0]
    }

    param_grid_naive_bayes_tfidf = {
        'TF-IDF__stop_words': ['english', None],
        'TF-IDF__ngram_range': [(1, 1), (1, 2), (2, 2)],
        'Naive_Bayes__alpha': [0.1, 1.0]
    }

    param_grid_decision_tree = {
        'Count_Vectorizer__stop_words': ['english', None],
        'Count_Vectorizer__ngram_range': [(1, 1), (1, 2), (2, 2)],
        'Decision_Tree__max_depth': [None, 5, 10]
    }

    param_grid_knn = {
        'Count_Vectorizer__stop_words': ['english', None],
        'Count_Vectorizer__ngram_range': [(1, 1), (1, 2), (2, 2)],
        'Nearest_Neighbors__n_neighbors': [3, 5, 7]
    }

    param_grid_svm = {
        'Count_Vectorizer__stop_words': ['english', None],
        'Count_Vectorizer__ngram_range': [(1, 1), (1, 2), (2, 2)],
        'SVM__C': [0.1, 1.0]
    }

    grid_search_naive_bayes_cv = GridSearchCV(
        estimator=Pipeline([
            ('Count_Vectorizer', CountVectorizer()),
            ('Naive_Bayes', MultinomialNB())
        ]),
        param_grid=param_grid_naive_bayes_cv,
        cv=10
    )

    grid_search_naive_bayes_tfidf = GridSearchCV(
        estimator=Pipeline([
            ('TF-IDF', TfidfVectorizer()),
            ('Naive_Bayes', MultinomialNB())
        ]),
        param_grid=param_grid_naive_bayes_tfidf,
        cv=10
    )

    grid_search_decision_tree = GridSearchCV(
        estimator=Pipeline([
            ('Count_Vectorizer', CountVectorizer()),
            ('Decision_Tree', DecisionTreeClassifier())
        ]),
        param_grid=param_grid_decision_tree,
        cv=10
    )

    grid_search_knn = GridSearchCV(
        estimator=Pipeline([
            ('Count_Vectorizer', CountVectorizer()),
            ('Nearest_Neighbors', KNeighborsClassifier())
        ]),
        param_grid=param_grid_knn,
        cv=10
    )

    grid_search_svm = GridSearchCV(
        estimator=Pipeline([
            ('Count_Vectorizer', CountVectorizer()),
            ('SVM', SVC())
        ]),
        param_grid=param_grid_svm,
        cv=10
    )

    # Perform grid search and get the best parameters and score for each pipeline
    best_params_scores = []

    for grid_search, pipeline_name in zip(
            [grid_search_naive_bayes_cv, grid_search_naive_bayes_tfidf, grid_search_decision_tree, grid_search_knn, grid_search_svm],
            ['Naive-Bayes + CountVectorizer', 'Naive-Bayes + TF-IDF', 'Decision_Tree', 'KNN', 'SVM']
    ):
        grid_search.fit(data.data, data.target)
        best_params = grid_search.best_params_
        best_score = grid_search.best_score_
        best_params_scores.append((pipeline_name, best_params, best_score))

    # Print the best parameters and scores for each pipeline
    for pipeline_name, best_params, best_score in best_params_scores:
        print(f"Best parameters for {pipeline_name} pipeline: {best_params}")
        print(f"Best cross-validation score for {pipeline_name} pipeline: {best_score}")
        print()
