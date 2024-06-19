'''
Ryan Aday
doc2csv.py

Version 1.0: 06/19/2024

Objective:
- Read all .docx within the directory where this is pasted tobytes
- Create a .csv file with 'Text' and 'Header' columns:
    - Text-  All sentences present within document
    - Header- The appropriate assigned header to each sentences
    - .csv file is named "output.csv", present in the same directory as this program

Nuances:
- Deletes all files with "~"
    - These are cached files, and will not be interpreted incorrectly by python-docx
- Requires the following libraries:
        python-docx (Needed for parsing through .docx documents)
        os  (Need for file name recogni
        csv (Needed for .csv editability)
        concurrent  (This is for multithreading)
'''

import os, csv
from docx import Document
from docx.shared import Pt
from concurrent.futures import ThreadPoolExecutor

def process_docx(file_path):
    document = Document(file_path)
    header = None
    rows = []

    for para in document.paragraphs:
        if para.style.name.startswith('Header'):
            header = para.text
        elif para.style.name in ('Normal', 'para') and para.text.strip():
            rows.append((para.text, header))

    return rows

def main(input_folder, output_csv):
    with ThreadPoolExecutor() as executor:
        all_rows = []
        for filename in os.listdir(input_folder):
            # Delete all files that contain "~" (cached files)
            if "~" in filePath:
                os.remove(filePath)
            elif filename.endswith('.docx'):
                file_path = os.path.join(input_folder, filename)
                all_rows.extend(executor.submit(process_docx, file_path).result())
            else:

    with open(output_csv, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['Text', 'Header'])
        writer.writerows(all_rows)

if __name__ == '__main__':
    input_folder = os.getcwd()
    output_csv = 'output.csv'
    main(input_folder, output_csv)
    print(f"CSV file '{output_csv}' generated successfully.")
