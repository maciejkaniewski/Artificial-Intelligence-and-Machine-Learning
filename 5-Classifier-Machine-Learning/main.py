from sklearn.datasets import load_files
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.metrics import classification_report, accuracy_score, confusion_matrix
import matplotlib.pyplot as plt
import seaborn as sns

from data_processor import DataProcessor

# Load data
data = load_files("data", encoding="latin-1")

# Preprocess the loaded data
data_preprocessor = DataProcessor()
preprocessed_data = data_preprocessor.preprocess_data(data.data)

data_sets = {"Raw Dataset": data.data,
             "Preprocessed Dataset": preprocessed_data}

# Create a figure with two subplots
fig, axes = plt.subplots(1, 2, figsize=(16, 6))

for i, (config_name, data_set) in enumerate(data_sets.items()):
    # Split the data into training and testing sets (80% for training, 20% for testing)
    x_train, x_test, y_train, y_test = train_test_split(data_set, data.target, test_size=0.2, random_state=42)
    # Create a Bag-of-Words object
    bag_of_words_tokenizer = CountVectorizer()
    # Learn the vocabulary dictionary and transform the training data into feature vectors
    x_train_bow = bag_of_words_tokenizer.fit_transform(x_train)
    # Transform the testing data into feature vectors
    x_test_bow = bag_of_words_tokenizer.transform(x_test)
    # Create a Naive Bayes classifier
    classifier = MultinomialNB()
    # Train the classifier
    classifier.fit(x_train_bow, y_train)
    # Predict the labels for the test set
    y_pred = classifier.predict(x_test_bow)
    # Print accuracy and classification report
    print(f"{config_name} Accuracy:", accuracy_score(y_test, y_pred))
    print(f"{config_name} Classification Report:\n",
          classification_report(y_test, y_pred, target_names=data.target_names))
    # Plot confusion matrix
    ax = axes[i]
    sns.heatmap(confusion_matrix(y_test, y_pred), annot=True, fmt="d", cmap="Blues",
                xticklabels=data.target_names, yticklabels=data.target_names, ax=ax)
    ax.set_xlabel("Predicted")
    ax.set_ylabel("True")
    ax.set_title(f"{config_name} Confusion Matrix")

# Show the figure with both confusion matrices
plt.show()
