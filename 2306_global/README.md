# 2306_global

Estimating global bacterial matrices.  

## To-do  

First pass:  
- [x] Run treeshrink
- [ ] Output branch lengths before and after treeshrink  
- [ ] Add more to-dos  

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

#TODO: Check how many removed and branch lengths  
