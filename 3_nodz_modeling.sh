# to run alphafold with run_alphafold.sh, the sequences of interest are placed in "sequences" and the models will be made inside "nodz_out"
# alphafold.sh will need to be modified to suit your own system and installation of alphafold

# make subdirectories
mkdir sequences
mkdir nodz_out
mkdir Colours
mkdir PDBs
mkdir split_PDBs
mkdir split_PDBs_N
mkdir split_PDBs_C
mkdir Alignment # put the "protein_set_mafft.fasta" file from 2_nodz_phylogenetics in this folder before starting

# run alphafold2
chmod +x Scripts/run_alphafold.sh
nohup Scripts/run_alphafold.sh &
cd nodz_out
mkdir PDBs
find . -type f -name 'ranked_0.pdb' -print0 | while IFS= read -r -d '' file; do accession=$(basename "$(dirname "$(dirname "$file")")"); cp "$file" "PDBs/${accession}.pdb"; done # extract highest-scoring models for each protein
zip -r all_nodz_models.zip PDBs # zip file in case you need to transfer to another computer

# prepare files for structural domain comparison
perl Scripts/insert_star.pl Alignment/protein_set_mafft.fasta Alignment/protein_set_mafft_split.fasta 1052 # insert an asterisk character at position 1052 in the alignment file
sed 's/-//g' Alignment/protein_set_mafft_split.fasta > Alignment/proteins_split_nogaps.fasta # remove all gaps in the alignment file
python Scripts/split_PDB.py Alignment/proteins_split_nogaps.fasta PDBs split_PDBs # split the PDBs based on the presence of an asterisk in the fasta file
mv split_PDBs/*_N.pdb split_PDBs_N
mv split_PDBs/*_C.pdb split_PDBs_C

# align split PDB structures to a reference protein, and parse output
chmod +x Scripts/run_tmalign_v3.sh # make the TMalign script executable
Scripts/run_tmalign_v3.sh # run TMalign

python3 Scripts/extract_tmscore1.py split_PDBs_N split_PDBs_N/tmscore1_N.txt # extract the TMscore values for each N-terminus alignment (normalized to structure 1; the split PDB)
sed -i 's/\([A-Z0-9]\+\)$/\1_N/' split_PDBs_N/tmscore1_N.txt # specify N-term in the accessions
python3 Scripts/extract_tmscore1.py split_PDBs_C split_PDBs_C/tmscore1_C.txt # extract the TMscore values for each C-terminus alignment (normalized to structure 1; the split PDB)
sed -i 's/\([A-Z0-9]\+\)$/\1_C/' split_PDBs_C/tmscore1_C.txt # specify C-term in the accessions
cat split_PDBs_N/tmscore1_N.txt split_PDBs_C/tmscore1_C.txt > split_PDBs/all_tmscore1.txt

# assign colours to the RMSD values
python3 Scripts/colour_gradient_linear.py split_PDBs/all_tmscore1.txt  > Colours/all_tmscore1_colours.txt # map hex codes to all TMscore values

grep '_N' Colours/all_tmscore1_colours.txt > Colours/tmscore1_colours_N.txt # extract N-term scores
grep '_C' Colours/all_tmscore1_colours.txt > Colours/tmscore1_colours_C.txt # extract C-term scores
sed -i 's/_N//g' Colours/tmscore1_colours_N.txt # remove _N suffixes
sed -i 's/_C//g' Colours/tmscore1_colours_C.txt # remove _C suffixes

# make iTOL files for the colour annotations
cd Colours
sed -i 's/ /\t/g' tmscore1_colours_N.txt 
sed -i 's/ /\t/g' tmscore1_colours_C.txt 
echo -e "DATASET_COLORSTRIP\nSEPARATOR TAB\n\nDATASET_LABEL\tN-Term TMscore\n\nDATA" > tmscore1_header_N.txt
echo -e "DATASET_COLORSTRIP\nSEPARATOR TAB\n\nDATASET_LABEL\tC-Term TMscore\n\nDATA" > tmscore1_header_C.txt
cat tmscore1_header_N.txt tmscore1_colours_N.txt > iTOL_tmscore1_N.txt # format the file for an iTOL datastrip
cat tmscore1_header_C.txt tmscore1_colours_C.txt > iTOL_tmscore1_C.txt # format the file for an iTOL datastrip
cd ..