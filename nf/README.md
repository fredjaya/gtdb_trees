# Nextflow pipeline to estimate and test Q-matrices  

## Installation  

Download repo:  
```
git clone https://github.com/fredjaya/gtdb_trees.git
```  

Install mamba/conda environment:  
```
cd gtdb_trees/nf/
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

## Usage  

```
nextflow run main.nf \
	--loci "/mnt/data/dayhoff/home/u1070770/gtdb/00_data/r207_loci/*" \
	--taxa_list "/mnt/data/dayhoff/home/u1070770/gtdb/02_working/2306_phyla_test/test_taxa/*" \
	--n_threads 2 \ # For some reason IQ-TREE only detects a minimum of 2 threads when sbatched \
	--executor slurm
```
