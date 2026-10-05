# before this step, manually compiled a list of 5 additional NodZ protein sequences of interest, mainly those with functional evidence for function; "functional_nodz.fasta"

# make subdirectories
mkdir Clusters # make sure "functional_nodz.fasta" and "expanded_nodZ_uniprotkb.fasta" are in here
mkdir Alignment
mkdir Phylogeny

# refine protein set formatting
cdhit -i Clusters/expanded_nodZ_uniprotkb.fasta -c 0.85 -o Clusters/nodZ_uniprot_SI85.fasta # cluster by 85 % identity, will also create a .cluster file for later reference
cat Clusters/nodZ_uniprot_SI85.fasta Clusters/functional_nodz.fasta > Clusters/protein_set.fasta # add functionally annotated proteins to the dataset
perl Scripts/remove_fragments.pl Clusters/protein_set.fasta Clusters/protein_set_nofrag.fasta # remove fragment sequences
perl Scripts/modify_uniprotkb_headers.pl Clusters/protein_set_nofrag.fasta Clusters/final_protein_headers.fasta # modify TrEMBL headers to remove excess data
sed -E 's/^>(sp|tr)\|([^|]+)\|.*/>\2/' Clusters/final_protein_headers.fasta > Clusters/final_protein_set.fasta # additional header modification

# align proteins
mafft --thread 16 --maxiterate 1000 --localpair Clusters/final_protein_set.fasta > Alignment/protein_set_mafft.fasta # align the proteins

# generate a phylogeny with protein set
cp Alignment/protein_set_mafft.fasta Phylogeny
cd Phylogeny
iqtree2 -s protein_set_mafft.fasta -m MF --mset LG,WAG,JTT,Q.pfam,JTTDCMut,DCMut,VT,PMB,Blosum62,Dayhoff -T auto --prefix nodz_model
best_model=$(grep 'Best-fit' nodz_model.log | cut -f3 -d' ')
echo $best_model #Q.pfam+R9
iqtree2 -s protein_set_mafft.fasta -m $best_model --alrt 1000 -B 1000 -T auto --prefix nodz_phylogeny # Create the final phylogeny
cd ..