import argparse
import seaborn as sns
import joblib as joblib
import matplotlib.pyplot as plt
from sklearn.datasets import load_files
from sklearn.metrics import classification_report, accuracy_score, confusion_matrix

if __name__ == "__main__":

    # Parse CLI arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("-data", default="test_dataset", help="Path to the test dataset")
    args = parser.parse_args()

    # Load the trained model
    model = joblib.load('trained_model.pkl')

    # Load the new data using the same method as before
    new_data = load_files(args.data, encoding="latin-1")

    # Make predictions on the new data
    predictions = model.predict(new_data.data)

    # Calculate and print the accuracy
    print(f"Accuracy: {accuracy_score(new_data.target, predictions)}")

    # Print the classification report
    print("Classification Report:")
    print(classification_report(new_data.target, predictions, target_names=new_data.target_names))

    cm = confusion_matrix(new_data.target, predictions)

    # Display the confusion matrix
    plt.figure(figsize=(8, 6))
    sns.heatmap(cm, annot=True, fmt="d", cmap="Blues", xticklabels=new_data.target_names,
                yticklabels=new_data.target_names)
    plt.title("Confusion Matrix")
    plt.xlabel("Predicted Label")
    plt.ylabel("True Label")
    plt.show()
