# Estimating bacterial Q-matrices  

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

## Pipeline  

### 1. Input data  

### 2. Taxon selection  

Extract subtree from GTDB r207 tree for each phyla > 50 taxa:  
```
scripts/get_subtree.py data/gtdb_r207_bac120_unscaled.decorated.tree [phyla_taxa_list]
```

Run treeshrink for each phyla:
```
run_treeshrink.py --tree [pruned_phyla_tree]
```

Downsample phyla to $k=1000$ of the most phylogenetically diverse taxa:  
```
cd phyla/ge_1000/
for i in p__*; do 
	iqtree2 -k 1000 -te ${i}/pruned_treeshrink/output.tree -pre ${i}/${i}_pd1000
done
```
### 3. Initial model selection  


### 3.  

## Usage  


