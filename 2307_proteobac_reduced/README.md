# Downsampling proteobacteria  

The proteobacteria is the largest phylum (n=17k).  

Is it necessary to use all sequences to estimate a phyla-level Q-matrice, or finer?  

## To-do  
First pass:  
- [x] Prune RED tree  
- [x] Run PARNAS
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

### PARNAS  

Test run, does it work on 17k tips?:  
```
parnas -t p__Proteobacteria.phyla.tree -n 10
```  

Yes it does! Selected 10 representatives that cover 55.10% of overall proteobacteria diversity. 

Took < 5 minutes with < 32GB RAM. 

Now, that it works, let's bump n up:  
```
parnas -t p__Proteobacteria.phyla.tree -n 1000 --diversity diversity_n1000.csv
```  
~10 mins, < 35GB RAM.  

```
parnas -t p__Proteobacteria.phyla.tree -n 10000 --diversity diversity_n10000.csv > diversity_n10000.log
```  

Chosen representatives cover 99.28% of overall diversity.  

~6 hours with < 60GB RAM.  

#### Diversity representation summary  

| Representative taxa | % RED | Run time | Memory |
| ------------------- | ----- | -------- | ------ |
| 2                   | 28.18 |          |        |
| 7                   | 51.51 | ~5m      | <32GB  |
| 100                 | 75.66 |          |        |
| 500                 | 85.93 |          |        |
| 1000                | 89.63 | ~10m     | <35GB  |
| 3033                | 95.00 |          |        |
| 8873                | 99.00 |          |        |
| 9958                | 99.28 | ~6h      | <60GB  |

Planning ahead, select RED cut-offs according to RED distributions per GTDB's taxonomic rank.  

**Genus**  
RED < 0.1 will encompass most genera (idk 75%ish)  
RED < 0.15 encompasses all but a handful of genera, and ~5-10% on the family level.
```
parnas -t p__Proteobacteria.phyla.tree --cover --radius 0.15 --subtree 
```
