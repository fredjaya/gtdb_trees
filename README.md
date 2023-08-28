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

Next, count the frequency of best-fitting models across all loci to select
the most common ones for the starting models `-mset` for training:  
```
scripts/count_top_models.py combined.best_scheme > 04_model_selection/starting_models.txt
```

Example output:  
> [('Q.yeast', 73), ('LG', 27), ('Q.insect', 8), ('Q.pfam', 7), ('HIVw', 1), ('mtZOA', 1)]  
> Total loci: 117  
> Cut-off: 0.9  
> Selecting most frequent models up to 106 loci.  
> Starting models: Q.yeast,LG,Q.insect  

### 4. Training  

**Training modes**  

| Mode              | Name    | Fixed topology? | Linked branch lengths? |
| ----------------- | ------- | --------------- | ---------------------- |
| Unconstrained     | uncon   | No              | No                     |
| Semi-constrained  | semicon | No              | Yes                    |
| Fully-constrained | fullcon | Yes             | Yes                    |

#### 4a. Fully constrained
```
scripts/estimate_q.py \ 
	--mode fullcon \
	--loci 03_subset_loci/training_loci/ \
	-mset Q.yeast,LG,Q.insect \
	-te pruned_treeshrink/output.tree \
	-T 4 -v
```

#### 4b. Semi-constrained  
```
scripts/estimate_q.py \ 
	--mode semicon \
	--loci 03_subset_loci/training_loci/ \
	-mset Q.yeast,LG,Q.insect \
	-T 4 -v
```

#### 4c. Unconstrained  
```
# First remove empty sequences  
mkdir -p 05_uncon/complete_training_loci  
cd 05_uncon/complete_training_loci
for i in ../../03_subset_loci/*; do
	scripts/remove_empties.py $i;
done

# Train
scripts/estimate_q.py \ 
	--mode uncon \
	--loci 03_subset_loci/training_loci/ \
	-mset Q.yeast,LG,Q.insect \
	-T 4 -v
```

## To-do  

### First pass  

**Scripting**  
- [ ] Clean GTDB tree (remove annotations etc.; actually might be ok as 
treeshrink cleans it, just wont work for tiny groups.)   
- [x] ~~Re-do Pearsons for lower triangle only~~ Leave it.  
- [x] Add second constrained method  
- [x] Increase `-cmax 8`  
- [x] Log training processes i.e. which commands were used, some output  
- [x] Leave `--init-model` as LG  
- [x] Automate the script
- [ ] Diagnostic plots  

**Phylum tests**
- [ ] Run Margulisbacteria (n=53)  
- [ ] Run a n~500  
- [ ] Run a n~1000  
- [ ] How correlated are all these matrices? Pick the fastest one  

**Update GitHub README**  
- [ ] Explain input/output files for each step e.g. explain columns  
- [ ] Explain  different training modes and commands  
- [ ] Put training commands on GitHub  

**post iqtree issues**  
- [ ] best_scheme.nex comma error  
- [ ] init-model Q.yeast not found  

### Second pass  
**Subsampling test**  
- [ ] Subset a larger phylum e.g. $k=\{50,100,250,500\}$  
- [ ] Estimate Qs  
- [ ] Calculate Pearsons on them  
- [ ] Re-run on more  

**Global Qs**  
- [ ] Add to-dos later  

### Third pass  
- [ ] Remove redundant (highly similar) matrices  
- [ ] All vs. all testing  
