# the amino acid sequences of 48 descendants of a common ancestor (“N0”) of the rhizobial clade were assembled into "rhizobial_cluster.fasta"

# make subdirectories
mkdir Alignment
mkdir Phylogeny

# align proteins
mv rhizobial_cluster.fasta Alignment
mafft --thread 16 --maxiterate 1000 --localpair Alignment/rhizobial_cluster.fasta > Alignment/rhizobial_cluster_mafft.fasta # align the proteins

cp Alignment/rhizobial_cluster_mafft.fasta Phylogeny
cd Phylogeny
iqtree2 -s protein_set_mafft.fasta -m MF --mset LG,WAG,JTT,Q.pfam,JTTDCMut,DCMut,VT,PMB,Blosum62,Dayhoff -T auto --prefix nodz_model
best_model=$(grep 'Best-fit' nodz_model.log | cut -f3 -d' ')
echo $best_model #JTT+R5
iqtree2 -s rhizobial_cluster_mafft.fasta -m $best_model --alrt 1000 -B 1000 -T auto --prefix nodz_phylogeny # Create the final phylogeny
cd ..