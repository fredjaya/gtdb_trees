# 2306_phyla  

Some high-level stuff.  

Number of taxa per phyla.  

## To-do  

First pass:  
- [ ] Prepare taxa lists for all phyla with >50 taxa  
- [ ] Prune  
- [ ] Run treeshrink on all phyla  
- [ ] ID taxa with shrunk trees  
- [ ] Identify resource usage vs. BIC across subsets of taxa in a big phyla  

## r207 branch lengths  
```
../scripts/tree_length.py ../data/trees/gtdb_r207_bac120_unscaled.decorated.tree
```  
Total tree length: 6908.397739999869  
Distribution of branch lengths: `branch_length_histogram.png`  

## Removing long branches  

```
run_treeshrink.py -t ../data/trees/gtdb_r207_bac120_unscaled.decorated.tree
```  

#TODO: Check how many removed
