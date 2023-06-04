import joblib as joblib
from sklearn.svm import SVC
from sklearn.pipeline import Pipeline
from sklearn.datasets import load_files
from sklearn.model_selection import cross_val_score
from sklearn.feature_extraction.text import TfidfVectorizer

if __name__ == "__main__":
    data = load_files("data", encoding="latin-1")

    pipeline = Pipeline([
        ('TF-IDF', TfidfVectorizer(ngram_range=(1, 2), stop_words='english')),
        ('SVM', SVC(C=25, gamma='scale', kernel='sigmoid'))
    ])

    scores = cross_val_score(pipeline, data.data, data.target, cv=10, n_jobs=-1)
    mean_accuracy = scores.mean()
    print(f"Mean Accuracy: {mean_accuracy}")

    pipeline.fit(data.data, data.target)
    joblib.dump(pipeline, 'trained_model.pkl')