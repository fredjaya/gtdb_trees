# Estimating bacterial Q-matrices  

Nextflow pipeline to estimate and test reversible Q-matrices.  

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


## Usage  


