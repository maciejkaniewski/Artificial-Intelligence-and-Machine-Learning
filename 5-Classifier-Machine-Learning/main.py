from typing import Any

from sklearn.datasets import load_files
from sklearn.model_selection import cross_val_score
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import Pipeline

from tabulate import tabulate


def perform_text_classification(data_set, text_clf_pipeline) -> list[tuple[list[Any], float]]:
    pipeline_methods = [step[1] for step in text_clf_pipeline.steps]
    print("Classification Pipeline:", pipeline_methods)
    # Store the results
    results = []
    # Train the classifier using cross-validation
    cv_scores = cross_val_score(text_clf_pipeline, data_set, data.target, cv=10)
    # Print cross-validation scores
    print("Mean Cross-Validation Score:", cv_scores.mean())
    print("Cross-Validation Score Variance:", cv_scores.var())
    print()
    # Print accuracy and classification report
    results.append((pipeline_methods, cv_scores.mean()))
    return results


if __name__ == "__main__":

    # Load data
    data = load_files("data", encoding="latin-1")

    classification_results = [perform_text_classification(
        data.data,
        Pipeline(
            [
                ('Bag_Of_Words', CountVectorizer(stop_words='english')),
                ('Naive_Bayes', MultinomialNB()),
            ],
        )), perform_text_classification(
        data.data,
        Pipeline(
            [
                ('Bigram', CountVectorizer(ngram_range=(2, 2), stop_words='english')),
                ('Naive_Bayes', MultinomialNB()),
            ],
        )), perform_text_classification(
        data.data,
        Pipeline(
            [
                ('TF-IDF', TfidfVectorizer(stop_words='english')),
                ('Naive_Bayes', MultinomialNB()),
            ],
        ))]

    table_data = []
    for outer_list in classification_results:
        pipeline_methods = ', '.join(str(step) for step in outer_list[0][0])
        accuracy_values = [entry[1] for entry in outer_list]
        accuracy_values = [str(value) for value in accuracy_values]
        table_data.append([pipeline_methods] + accuracy_values)

    print(tabulate(table_data, headers=['Classification Pipeline', 'Mean Cross-Validation Score'], tablefmt='grid'))
    print()

    best_result = max([item for sublist in classification_results for item in sublist], key=lambda x: x[1])

    print(f"The best model is {best_result[0]} with {round(best_result[1] * 100, 2)}% "f"mean cross-validation score.")
