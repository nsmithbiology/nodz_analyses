# Prior to starting, ensure the directory has the hmmDatabaseFiles directory, the Intermediate directory with the combined proteome, and the Scripts folder. Also have a folder called downloaded_HMM_files with the desired .hmm
# for instructions on making the required hmm database and proteome database, see Smith et al (2025) https://github.com/diCenzo-Lab/013_2025_Fkp_analyses

# Make working directories and set up file organization
mkdir HMMsearch
mkdir HMMsearchParsed
mkdir HMMsearchHits
mkdir HMMscan
mkdir HMMscanParsed
mkdir HMMscanTop
mkdir HMM_files #ensure that PF05830.hmm is in this folder

# Prepare HMM files
echo PF05830 > HMM_files/HMM_list.txt # create a txt file containing the name of the desired HMM
cp downloaded_HMM_files/PF05830.hmm HMM_files/ # move txt file to the HMM_files directory 

# Perform the HMMsearch
perl Scripts/performHMMsearch.pl HMM_files/HMM_list.txt # a short script to repeat for all HMM files, the build, hmmsearch, parsing, and hit extraction
mv HMMsearchHits/*.faa HMMsearchHits/allHits.fasta # rename the parsed file to "allHits.fasta"
perl Scripts/modifyFasta.pl HMMsearchHits/allHits.fasta > HMMsearchHits/allHits_modified.fasta # modify the fasta file for easy sorting
sort -u HMMsearchHits/allHits_modified.fasta > HMMsearchHits/allHits_temp.faa # get just the unique hits
perl Scripts/splitFasta.pl HMMsearchHits/allHits_temp.faa > HMMsearchHits/allHits.faa # modify fasta format

# Perform the HMMscan screens for pf05830
hmmscan --cpu 16 hmmDatabaseFiles/converted_combined.hmm HMMsearchHits/allHits.faa > HMMscan/allHits.txt # run the hmmscan analysis
perl Scripts/parseHMMscan.pl HMMscan/allHits.txt > HMMscanParsed/allHits.csv # parse the hmmscan output file
perl Scripts/HMMscanTopHit.pl HMMscanParsed/allHits.csv > HMMscanTop/allHits.csv # find the top hit for each protein
perl Scripts/parseHMMscanHits_pf05830.pl HMMscanTop/allHits.csv > HMMscanTop/pf05830_names.txt # a script to extract the names of proteins that have top hits to the desired HMM
perl Scripts/extractHMMscanHits.pl HMMscanTop/pf05830_names.txt > HMMscanTop/pf05830scan.faa # extract the proteins

# Filter based on size constraints
pullseq -i HMMscanTop/pf05830scan.faa -m 200 -a 480 > HMMscanTop/pf05830sizefilter.faa # extract only sequences between 200 and 480 in length

# Filter out sequences with ambiguous X residues
perl Scripts/filterX.pl HMMscanTop/pf05830sizefilter.faa HMMscanTop/pf05830sizeXFilter.faa

# the final uniref50 accessions are contained in pf05830sizeXFilter.faa
# used uniprot to manually downloaded the 327 uniprotkb protein sequences from each uniref50 cluster, giving "expanded_nodZ_uniprotkb.fasta" - this will be used in next steps

