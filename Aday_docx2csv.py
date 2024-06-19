import os
import csv
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
