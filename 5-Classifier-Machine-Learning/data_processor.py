import nltk
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
import string


class DataProcessor:
    """
    Class used to preprocessing text data.
    """

    def __init__(self):
        """
        DataProcessor constructor.
        """
        nltk.download('punkt', download_dir='ntlk_data')
        nltk.download('stopwords', download_dir='ntlk_data')
        nltk.data.path.append('ntlk_data')
        self.stop_words = set(stopwords.words('english'))

    def preprocess_text(self, text) -> str:
        """
        Performs preprocessing operations on single text record.
        :param text: Single text record to be preprocessed.
        :return: Lowercase text, without punctuation and stopwords.
        """
        text = text.lower()
        text = text.translate(str.maketrans("", "", string.punctuation))
        tokens = word_tokenize(text)
        filtered_tokens = [word for word in tokens if word not in self.stop_words]
        preprocessed_text = ' '.join(filtered_tokens)
        return preprocessed_text

    def preprocess_data(self, data) -> list[str]:
        """
        Performs preprocess_text() on whole dataset.
        :param data: Dataset to be preprocessed.
        :return: Preprocessed dataset.
        """
        preprocessed_data = []
        for text in data:
            preprocessed_text = self.preprocess_text(text)
            preprocessed_data.append(preprocessed_text)
        return preprocessed_data
