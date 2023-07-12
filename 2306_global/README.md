# 2306_global

Estimating global bacterial matrices.  

## To-do  

First pass:  
- [x] Run treeshrink
- [x] Output branch lengths before and after treeshrink  
- [x] Run PARNAS
- [ ] Estimate with different parameters
- [ ] Scale to ultrametric
- [ ] Run treeshrink
- [ ] Output branch lengths before and after treeshrink  

## Unscaled r207 tree  

### Branch lengths  
```
../scripts/tree_length.py ../data/trees/gtdb_r207_bac120_unscaled.decorated.tree
```  
Total tree length: 6908.397739999869  
Distribution of branch lengths: `branch_length_histogram.png`  

## r207 molecular/unscaled

### Removing long branches with treeshrink

#### alpha = 0.05
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

#### alpha = 0.10

52 dropped:

| Order/Family                                                                              | Count |
| ----------------------------------------------------------------------------------------- | ----- |
| p__Proteobacteria; c__Alphaproteobacteria; o__Rhodobacterales; f__Rhodobacteraceae        | 22    |
| p__Proteobacteria; c__Alphaproteobacteria; o__Rickettsiales                               | 2     |
| p__Proteobacteria; c__Gammaproteobacteria; o__Enterobacterales_A; f__Enterobacteriaceae_A | 3     |
| p__Firmicutes; c__Bacilli; o__Mycoplasmatales                                             | 25    |

### Downsampling with PARNAS  

## r207 RED-scaled  

The relative evolutionary distance (RED) scales trees so that terminal branches are `RED=1` and the root node is `RED=0`. Everything inbetween is interpolated. 

Rescale:
```
phylorank outliers \
        ../data/trees/gtdb_r207_bac120_unscaled.decorated.tree \
	~/Dropbox/gtdb/00_raw_data/gtdb_r207_bac120_curation_taxonomy.tsv \
	~/Dropbox/gtdb/01_data/r207_phylorank
``` 

Tree length: 5036.834222551443  

### Treeshrink  

```
~/GitHub/TreeShrink/run_treeshrink.py -t red/gtdb_r207_bac120_unscaled.decorated.scaled.tree -o red_shrunk -q "0.05 0.10"
```

No abnormally long branches with either threshold!  

### PARNAS   

**Genus**  
The median RED of GTDB r207 genera is approximately ~0.925, hopefully this should downsample so that one sequence represents each genus?:  
```
parnas -t red/gtdb_r207_bac120_unscaled.decorated.scaled.tree --cover --radius 0.15 --subtree red_parnas/red_r015.tree
```

20,571 taxa retained!

**Family**  
Median RED of families are ~0.76. RED<0.7 should give a single representative for > 85%ish of families. The rest are multiple species per family and like ~5% reps for orders:  

```
parnas -t red/gtdb_r207_bac120_unscaled.decorated.scaled.tree --cover --radius 0.3 --subtree red_parnas/red_r03.tree
```
