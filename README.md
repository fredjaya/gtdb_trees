# Estimating bacterial Q-matrices  

Analysis files on [Dropbox](https://www.dropbox.com/sh/pfsew90nisv8k1l/AADSdnqcUheiS44skXUtomr0a?dl=0)  

## Installation  

Download repo:  
```
git clone https://github.com/fredjaya/gtdb_trees.git
```  

Install mamba/conda environment:  
```
cd gtdb_trees/
mamba env create -f env.yml
mamba activate gtdb-nf
```

Install faSomeRecords and AliStat:

```
cd bin/ 
# faSomeRecords
wget https://raw.githubusercontent.com/santiagosnchez/faSomeRecords/master/faSomeRecords.py
chmod +x faSomeRecords.py

# AliStat
wget https://github.com/thomaskf/AliStat/archive/refs/tags/v1.14.tar.gz
tar -xzvf v1.14.tar.gz
rm v1.14.tar.gz
cd AliStat-1.14/
make
mv alistat ../
cd ../
rm -r AliStat-1.14/
```

## Steps  

### 1. Input data  

### 2. Taxon selection  

Extract subtree from GTDB r207 tree for each phyla > 50 taxa:  
```
scripts/get_subtree.py data/gtdb_r207_bac120_unscaled.decorated.tree [phyla_taxa_list]
```

Output tree length and branch length distributions:  
```
scripts/tree_length.py [tree_file]
```  

Run treeshrink for each phyla:
```
run_treeshrink.py --tree [pruned_phyla_tree]
```

Output tree length and branch length distributions:  
```
scripts/tree_length.py [tree_file]
```  

Downsample phyla to $k=1000$ of the most phylogenetically diverse taxa:  
```
# Identify the k taxa
cd phyla/ge_1000/
for i in p__*; do 
	iqtree2 -k 1000 -te ${i}/pruned_treeshrink/output.tree -pre ${i}/${i}_pd1000
done

# Parse subtree  
for i in p__*; do
	grep -A1 "Corresponding sub-tree" ${i}/${i}_pd1000.pda | \
	tail -1 > ${i}/pruned_pd1000.tree
done
```  

Subset taxa across all 120 loci:  
```
mkdir -p 00_subset_taxa
for loc in ~/Dropbox/gtdb/01_data/gtdb_r207_full_concat/*.faa; do
	faSomeRecords.py --fasta $loc --list [taxa_list] --outfile 00_subset_taxa/${loc}
```

### 2. Subset loci  
Run AliStat to identify most complete loci:  
```
# cd to a phyla dir  
for i in 00_subset_taxa/*; alistat $i 6 -b | tail -n1; done > 01_alistat.csv
subset_loci_ca.R 01_alistat 100

mkdir 02_loci_assignment/training_loci 02_loci_assignment/testing_loci

# Arrange loci into training and testing directories  
for i in `cat 01_alistat/training_loci.txt`; do 
	cp $i 03_subset_loci/training_loci/
done

for i in `cat 01_alistat/testing_loci.txt`; do 
	cp $i 03_subset_loci/testing_loci/
done
```

### 3. Initial model selection  

Test the best-fitting model per-locus to determine the starting models
for training:  
```
# Run model selection
mkdir 04_model_selection
iqtree2 -S 03_subset_loci/training_loci -T 4 -pre 04_model_selection/training_loci 
iqtree2 -S 03_subset_loci/testing_loci -T 4 -pre 04_model_selection/testing_loci   
cat 04_model_selection/*.best_scheme > 04_model_selection/combined.best_scheme
```

### 4. Training  

First concatenate training and testing loci and generate partition files:  
```
AMAS.py concat -i 03_subset_loci/training_loci/* -f fasta -d aa -p 03_subset_loci/training.partitions -t 03_subset_loci/training_concat.faa -u fasta -y nexus
AMAS.py concat -i 03_subset_loci/testing_loci/* -f fasta -d aa -p 03_subset_loci/testing.partitions -t 03_subset_loci/testing_concat.faa -u fasta -y nexus
```

Run:  
```
# For p__Firestonebacteria  
# First did some manual cleaning of node labels from phylorank

cd ~/Dropbox/gtdb/02_working/2308_phyla/lt_1000/p__Firestonebacteria
scripts/estimate_q.py --best_scheme 04_model_selection/combined.best_scheme -l ~/Dropbox/gtdb/01_data/gtdb_r207_full_concat/ -te 
```
