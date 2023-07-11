# 2306_global

Estimating global bacterial matrices.  

## To-do  

First pass:  
- [x] Run treeshrink
- [x] Output branch lengths before and after treeshrink  
- [ ] Run PARNAS
- [ ] Estimate with different parameters
- [ ] Scale to ultrametric
- [x] Run treeshrink
- [ ] Output branch lengths before and after treeshrink  

## r207 molecular

### Branch lengths  
```
../scripts/tree_length.py ../data/trees/gtdb_r207_bac120_unscaled.decorated.tree
```  
Total tree length: 6908.397739999869  
Distribution of branch lengths: `branch_length_histogram.png`  

#### Removing long branches  

##### alpha = 0.05
```
run_treeshrink.py -t ../data/trees/gtdb_r207_bac120_unscaled.decorated.tree
```  

Check number of taxa dropped:
```
grep -oP "\t" gtdb_r207_bac120_unscaled.decorated_treeshrink/output.txt | wc -l
```  

19 dropped. Check which species:
```
for i in `sed 's/\t\/\n/g' gtdb_r207_bac120_unscaled.decorated_treeshrink/output.txt`; do grep $i ~/Dropbox/gtdb/01_data/gtdb_r207_bac120_curation_taxonomy_tabbed.tsv; done > dropped_spp.txt
```  

| Order                                                            | Count |
| ---------------------------------------------------------------- | ----- |
| p__Firmicutes; c__Bacilli; o__Mycoplasmatales                    | 16    |
| p__Proteobacteria; c__Alphaproteobacteria; o__Rickettsiales      | 2     |
| p__Proteobacteria  c__Gammaproteobacteria  o__Enterobacterales_A | 1     |  

Total tree length: 6899.0687299998635

##### alpha = 0.10



