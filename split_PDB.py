import os
import argparse

def parse_fasta(fasta_file):
    sequences = {}
    with open(fasta_file, 'r') as file:
        sequence_id = None
        sequence = ''
        for line in file:
            line = line.strip()
            if line.startswith('>'):
                if sequence_id:
                    sequences[sequence_id] = sequence
                sequence_id = line[1:]  # Take the whole line after '>' as the sequence ID
                sequence = ''
            else:
                sequence += line
        if sequence_id:
            sequences[sequence_id] = sequence
    return sequences

def split_pdb(sequence_id, sequence, pdb_dir, output_dir):
    pos = sequence.find('*')
    if pos == -1:
        print("No '*' found in sequence {}".format(sequence_id))
        return

    pdb_file = os.path.join(pdb_dir, "{}.pdb".format(sequence_id))
    print("Looking for PDB file: {}".format(pdb_file))
    if not os.path.exists(pdb_file):
        print("PDB file {} does not exist".format(pdb_file))
        return

    n_terminal_file = os.path.join(output_dir, "{}_N.pdb".format(sequence_id))
    c_terminal_file = os.path.join(output_dir, "{}_C.pdb".format(sequence_id))

    print("Creating N-terminal file: {}".format(n_terminal_file))
    print("Creating C-terminal file: {}".format(c_terminal_file))

    with open(pdb_file, 'r') as pdb, \
         open(n_terminal_file, 'w') as n_out, \
         open(c_terminal_file, 'w') as c_out:
        
        for line in pdb:
            if line.startswith('ATOM'):
                res_num = int(line[22:26].strip())
                if res_num <= pos:
                    n_out.write(line)
                else:
                    c_out.write(line)

    print("Generated files for {}: {} and {}".format(sequence_id, n_terminal_file, c_terminal_file))

def main():
    parser = argparse.ArgumentParser(description="Split PDB models into N- and C-termini based on FASTA sequences.")
    parser.add_argument('fasta_file', type=str, help='FASTA file containing sequences')
    parser.add_argument('pdb_dir', type=str, help='Directory containing PDB files')
    parser.add_argument('output_dir', type=str, help='Directory to save split PDB files')

    args = parser.parse_args()

    print("FASTA file: {}".format(args.fasta_file))
    print("PDB directory: {}".format(args.pdb_dir))
    print("Output directory: {}".format(args.output_dir))

    # Check if output directory exists, create it if not
    if not os.path.exists(args.output_dir):
        os.makedirs(args.output_dir)

    # Process the single FASTA file
    print("Processing FASTA file: {}".format(args.fasta_file))
    sequences = parse_fasta(args.fasta_file)
    for sequence_id, sequence in sequences.items():
        print("Processing sequence: {}".format(sequence_id))
        split_pdb(sequence_id, sequence, args.pdb_dir, args.output_dir)

if __name__ == "__main__":
    main()
