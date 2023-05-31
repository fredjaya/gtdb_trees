# 2306_nitrospinota  

Run a fast and complete pipeline for a decently sized phyla. Was going to choose Nitrospirota but it's a bit big. Chose Nitrospinota because it looks problematic (i.e. Nitrosponita and Nitrosponita_B).  

- [x] Create taxa list with both Nitrospinota and Nitrospinota_B taxa  
- [x] Calculate total tree length of r207 tree (place in `/phyla` and rename dir)
- [x] Output distribution of branch lengths of r207 tree  
- [ ] Prune taxa from r207 tree  
- [ ] Get new tree and branch lengths
- [ ] Run treeshrink
- [ ] Get new tree and branch lengths
- [ ] Run unconstrained estimation on treeshrinked tree
- [ ] Output stats (expand later)

Bonus:
- [ ] Run estimation on pruned (pre-treeshrinked) tree

## Taxa list  
```
grep 'Nitrospinota' ../2306_phyla/data/gtdb_r207_bac120_curation_taxonomy_tabbed.tsv | cut -f1 > nitrospirota_taxa.txt
```  

62 taxa (2 are \_B).  

## Prune tree  

Before training, check if any taxa are on abnormally long branches.  

Get Nitrospinota subtree from reference tree:  
```
../scripts/get_subtree.py ../data/trees/gtdb_r207_bac120_unscaled.decorated.tree nitrospinota.taxa
```  

Get branch lengths:  
```
../scripts/tree_length.py pruned.tree
```  

Tree length: 11.898950000000001  

