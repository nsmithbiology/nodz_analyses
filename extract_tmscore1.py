import os
import re
import argparse

def extract_tm_score(file_path):
    with open(file_path, 'r') as file:
        content = file.read()
    
    # Find the TM-score normalized by length of Chain_1
    match = re.search(r'TM-score=\s*([\d\.]+)\s*\(if normalized by length of Chain_1\)', content)
    
    if match:
        tm_score = float(match.group(1))
        return tm_score
    else:
        print(f"No TM-score found in {file_path}")
        return None

def process_directory(directory):
    results = []
    for filename in os.listdir(directory):
        if filename.endswith("_tmalign.txt"):
            filepath = os.path.join(directory, filename)
            tm_score = extract_tm_score(filepath)
            if tm_score is not None:
                accession = filename.replace("_C_tmalign.txt", "").replace("_N_tmalign.txt", "")
                results.append((tm_score, accession))
    
    return results

def save_results(results, output_file):
    with open(output_file, 'w') as file:
        for tm_score, accession in results:
            file.write(f"{tm_score}\t{accession}\n")

def main():
    parser = argparse.ArgumentParser(description="Extract TM-score from TMalign output files")
    parser.add_argument('directory', type=str, help='Directory containing TMalign output files')
    parser.add_argument('output_file', type=str, help='File to save the extracted TM-scores')

    args = parser.parse_args()

    results = process_directory(args.directory)
    save_results(results, args.output_file)

if __name__ == "__main__":
    main()
