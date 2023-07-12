# Downsampling proteobacteria  

The proteobacteria is the largest phylum (n=17k).  

Is it necessary to use all sequences to estimate a phyla-level Q-matrice, or finer?  

## To-do  
- [ ] Run estimation on variable n subsets

First pass:  
- [ ] Prune RED tree  
- [ ] Run PARNAS
- [ ] Run PARNAS with various n
- [ ] Run estimation on variable n subsets

Second pass:  
- [ ] Compare between unscaled and RED-scaled tree  
- [ ] Run PARNAS with various n with variable n  

## RED scaled  

Prune proteobacteria from RED-scaled tree from `2306_global`:  
```
../scripts/get_subtree.py ../2306_global/red/gtdb_r207_bac120_unscaled.decorated.scaled.tree ../2306_phyla/taxa/lists/p__Proteobacteria.phyla 
```  
