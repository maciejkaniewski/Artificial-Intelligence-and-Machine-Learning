import os


def find_matching_files(loaded_directory, search_directory):
    matching_files = set()
    matching_loaded_files = set()

    for loaded_file_name in os.listdir(loaded_directory):
        loaded_file_path = os.path.join(loaded_directory, loaded_file_name)
        if os.path.isfile(loaded_file_path):
            with open(loaded_file_path, 'r', encoding='latin-1') as loaded_file:
                loaded_content = loaded_file.read()

            for root, dirs, files in os.walk(search_directory):
                for file_name in files:
                    if file_name.endswith('.txt'):
                        file_path = os.path.join(root, file_name)
                        with open(file_path, 'r', encoding='latin-1') as search_file:
                            search_content = search_file.read()
                        if loaded_content in search_content:
                            matching_files.add(file_path)
                            matching_loaded_files.add(loaded_file_path)

    return matching_files, matching_loaded_files


# Define your directories
directories = [('bbc/business', 'data/business'),
               ('bbc/entertainment', 'data/entertainment'),
               ('bbc/politics', 'data/politics'),
               ('bbc/sport', 'data/sport'),
               ('bbc/tech', 'data/tech')]

for loaded_directory, search_directory in directories:
    matching_files, matching_loaded_files = find_matching_files(loaded_directory, search_directory)
    matching_file_count = len(matching_files)

    if matching_file_count > 0:
        print(f"Matching files found in {search_directory}: {matching_file_count}")
        for matching_file, matching_loaded_file in zip(matching_files, matching_loaded_files):
            os.remove(matching_loaded_file)
