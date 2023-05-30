from typing import List, Tuple, Any

from sklearn.datasets import load_files
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.metrics import classification_report, accuracy_score, confusion_matrix
from sklearn.pipeline import Pipeline
import matplotlib.pyplot as plt
import seaborn as sns

import argparse
from tabulate import tabulate

from data_processor import DataProcessor


def perform_text_classification(data_sets, text_clf_pipeline, enable_plot) -> list[tuple[list[Any], Any, float]]:
    pipeline_methods = [step[1] for step in text_clf_pipeline.steps]
    print("Classification Pipeline:", pipeline_methods)

    # Store the results
    results = []

    # Create a figure with two subplots
    if enable_plot:
        fig, axes = plt.subplots(1, 2, figsize=(16, 6))

    for i, (config_name, data_set) in enumerate(data_sets.items()):
        # Split the data into training and testing sets (80% for training, 20% for testing)
        x_train, x_test, y_train, y_test = train_test_split(data_set, data.target, test_size=0.2, random_state=42)
        # Train the classifier
        text_clf_pipeline.fit(x_train, y_train)
        # Predict the labels for the test set
        y_pred = text_clf_pipeline.predict(x_test)
        # Print accuracy and classification report
        results.append((pipeline_methods, config_name, accuracy_score(y_test, y_pred)))
        print(f"{config_name} Accuracy:", accuracy_score(y_test, y_pred))
        print(f"{config_name} Classification Report:\n",
              classification_report(y_test, y_pred, target_names=data.target_names))
        # Plot confusion matrix
        if enable_plot:
            sns.heatmap(confusion_matrix(y_test, y_pred), annot=True, fmt="d", cmap="Blues",
                        xticklabels=data.target_names, yticklabels=data.target_names, ax=axes[i])
            axes[i].set_xlabel("Predicted")
            axes[i].set_ylabel("True")
            axes[i].set_title(f"{config_name} Confusion Matrix")

    print()
    if enable_plot:
        fig.text(0.5, 0.95, pipeline_methods, transform=fig.transFigure,
                 horizontalalignment='center', verticalalignment='center', fontsize=12)
        plt.show()
    return results


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Text Classification')
    parser.add_argument('-p', action='store_true', help='Enable plotting confusion matrices')
    args = parser.parse_args()

    # Load data
    data = load_files("data", encoding="latin-1")

    # Preprocess the loaded data
    data_preprocessor = DataProcessor()
    preprocessed_data = data_preprocessor.preprocess_data(data.data)

    data_sets = {"Raw Dataset": data.data,
                 "Preprocessed Dataset": preprocessed_data}

    classification_results = []

    classification_results.append(
        perform_text_classification(
            data_sets,
            Pipeline(
                [
                    ('Bag_Of_Words', CountVectorizer()),
                    ('Naive_Bayes', MultinomialNB()),
                ],
            ), args.p))

    classification_results.append(
        perform_text_classification(
            data_sets,
            Pipeline(
                [
                    ('Bigram', CountVectorizer(ngram_range=(2, 2))),
                    ('Naive_Bayes', MultinomialNB()),
                ],
            ), args.p))

    table_data = []
    for outer_list in classification_results:
        pipeline_methods = ', '.join(str(step) for step in outer_list[0][0])
        accuracy_values = [entry[2] for entry in outer_list]
        accuracy_values = [str(value) for value in accuracy_values]
        table_data.append([pipeline_methods] + accuracy_values)

    print(tabulate(table_data, headers=['Pipeline Methods', 'Raw Dataset', 'Preprocessed Dataset'], tablefmt='grid'))
    print()

    flattened_list = [item for sublist in classification_results for item in sublist]
    best_result = max(flattened_list, key=lambda x: x[2])

    print("Best Accuracy:", best_result[2])
    print("Pipeline Methods:", best_result[0])
    print("Dataset Type:", best_result[1])
