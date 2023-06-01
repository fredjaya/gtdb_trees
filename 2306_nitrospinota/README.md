# 2306_nitrospinota  

Run a fast and complete pipeline for a decently sized phyla. Was going to choose Nitrospirota but it's a bit big. Chose Nitrospinota because it looks problematic (i.e. Nitrosponita and Nitrosponita_B).  

**Complete files and analyses moved to https://www.dropbox.com/home/gtdb/02_working/2306_nitrospinota due to exceeding LFS cap**  

- [x] Create taxa list with both Nitrospinota and Nitrospinota_B taxa  
- [x] Calculate total tree length of r207 tree (place in `/phyla` and rename dir)  
- [x] Output distribution of branch lengths of r207 tree  
- [x] Prune taxa from r207 tree  
- [x] Get new tree and branch lengths  
- [x] Run treeshrink  
- [x] Get new tree and branch lengths  

Nextflow steps:  
- [x] Subset alignments according to shrunk taxa  
- [x] Run unconstrained estimation on treeshrinked tree  

- [x] Run testing  

Training outputs:  
- [ ] n loci 
- [ ] alignment size  
- [ ] tree/branch lengths 
- [ ] rates bubble plot first and last iter 
- [ ] rates over iterations (line graph)  
- [ ] rates PCA  
- [ ] frequency PCA  

Testing outputs:  
- [ ] BIC and lnLs of training per loci 

Second pass:  
- [x] Run estimation on pruned (pre-treeshrinked) tree  
	- Doesn't apply to this subset because no shrinking occurred  
- [ ] Implement constrained analysis  
- [ ] Run constrained estimation on treeshrinked tree  
- [ ] Fix RHAS on subset with LG only  
- [ ] Add option to run test in a single command `-mset`  
	- qMaker does this  
	- Running existing and new Qs separately makes model selection per partition difficult  
	- `-m madd` does not do `+F,+I,+G,+R`  
## Dependencies  
- python3  
- biopython  
- matplotlib  
- numpy  
- treeshrink (conda version broken, need to use git repo)  
- nextflow  

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

## Prune long branches (treeshrink)  

```
run_treeshrink -t pruned.tree
```  

No tips removed! (sanity check: tree length of output tree identical)  

## Training  

For now, run the nf pipeline to get the (iterative) training going:  
```
nextflow run ../nf/main.nf \
	--outdir $PWD \
	--loci "../data/alignments/full_loci/*.faa" \
	--taxa_list nitrospinota.taxa \
	--n_training_loci 100
```  

i4 iterations for training completed under 14 hours with 4 cores and < 2GB RSS.

## Testing  

Moved to Dropbox because lfs cp exceeded.  

```
cd ~/Dropbox/gtdb/02_working/2306_nitrospinota/05_manual_train
iqtree2 -seed 1 -T 8 -m MFP -pre test_mset_28existing \
	-S ../03_subset_loci/nitrospinota/testing_loci/ \
	-mset "${estimated_Q},Blosum62,cpREV,Dayhoff,DCMut,FLAVI,FLU
,HIVb,HIVw,JTT,JTTDCMut,LG,mtART,mtMAM,mtREV,mtZOA,mtMet,mtVer,mtInv
,PMB,Q.bird,Q.insect,Q.mammal,Q.pfam,Q.plant,Q.yeast,rtREV,VT,WAG"
```
