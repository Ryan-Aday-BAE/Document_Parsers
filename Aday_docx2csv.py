def printHeader():
    print("""\
    Ryan Aday
    doc2csv.py

    Version 1.0: 06/19/2024

    Objective:
    - Read all .docx within the directory where this script is present in
    - Create a .csv file with 'Text' and 'Header' columns:
        - Text-  All sentences present within document
        - Header- The appropriate assigned header to each sentences
        - .csv file is named "output.csv", present in the same directory as this program

    Nuances:
    - Deletes all files with "~"
        - These are cached files, and will not be interpreted incorrectly by python-docx
    - Deletes all sentences with unique headers (classification stratification)
    - Requires the following libraries:
            python-docx (Needed for parsing through .docx documents)
            os  (Need for file name recogni
            pandas (Need for dataframe, csv write)
            numpy (Need for NaN removal)
            concurrent  (This is for multithreading)
            tqdm (This is for the progress bar)
    """)

def process_docx(file_path):
    print(file_path)
    document = Document(file_path)
    header = None
    rows = []
    
    for para in tqdm(document.paragraphs):
        # print(para.style.name) # Check to see how text is styled in .docx
        if para.style.name.startswith('Head'):
            header = para.text
        elif not para.style.name.startswith(("table", "toc")) and para.text.strip():
            for sentence in re.split(r'(?<=\.) ', para.text.strip()):
                #if not header is None:
                rows.append((sentence, header))

    return rows

def main(input_folder, output_csv):
    # Clear terminal
    os.system('cls' if os.name == 'nt' else 'clear')
    printHeader()
    
    with ThreadPoolExecutor() as executor:
        all_rows = []
        for filename in os.listdir(input_folder):
            # Delete all files that contain "~" (cached files)
            if "~" in filename:
                os.remove(filename)
            elif filename.endswith('.docx'):
                file_path = os.path.join(input_folder, filename)
                all_rows.extend(executor.submit(process_docx, file_path).result())
            else:
                pass

    # Force utf-8 encoding to prevent misinterpreted characters.
    with open(output_csv, 'w', newline='', encoding="utf-8") as csvfile:
        #writer = csv.writer(csvfile)
        #writer.writerow(['Text', 'Header'])
        df = pd.DataFrame(all_rows, columns=['Text', 'Header'])
        df.replace('', np.nan, inplace=True)
        #df = df.replace(r'[^\w\s]|_', '', regex=True)
        df.drop_duplicates(subset=['Text'], keep="first", inplace=True)
        #df = df.apply(lambda x: x.astype(str).str.lower()).drop_duplicates(subset=['Text'], keep='first')
        df.dropna(inplace=True)        
        df = df[df.duplicated(subset=['Header'], keep=False)]
        df.to_csv(csvfile, encoding='utf-8', index=False)
        #all_rows = df.values.toList()       
        #writer.writerows(all_rows)

if __name__ == '__main__':
    try:
        import os, csv, re
        import pandas as pd
        import numpy as np
        from docx import Document
        from docx.shared import Pt
        from concurrent.futures import ThreadPoolExecutor
        from tqdm import tqdm
        
    except ImportError:
        sys.exit("""
            You need the os, csv, docx, and concurrent libraries.
            To install these libraries, please type:
            pip install pandas os csv python-docx concurrent tqdm textwrap
            """)

    input_folder = os.getcwd()
    output_csv = 'output.csv'
    try:
        main(input_folder, output_csv)
        print(f"CSV file '{output_csv}' generated successfully.")
    except:
        sys.exit("""
            This script should be pasted in the repository containing
            the docx files you want to review.
            """)
