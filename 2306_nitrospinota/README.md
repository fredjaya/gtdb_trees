# 2307_nitrospinota  

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
- [x] BICs over iter  
- [x] n loci 
- [ ] alignment size  
- [x] rates bubble plot first and last iter 
- [x] rates PCA  
- [x] frequency PCA  

Testing outputs:  
- [x] BIC and lnLs of locus trees best existing vs new  
- [x] branch and tree lengths of best existing vs new  
- [ ] alignment size

Second pass:  
- [x] Run estimation on pruned (pre-treeshrinked) tree  
	- Doesn't apply to this subset because no shrinking occurred  
- [x] Run separate testing on nitrospinota
- [ ] Run constrained estimation on treeshrinked tree  
- [ ] Implement constrained analysis in nf?  
- [ ] rates over iterations (line graph)  
- [ ] raw rates boxplots  

Third pass:  
- [ ] Move on to 2306_phyla   

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

## Unconstrained per-locus trees  

### Training  

For now, run the nf pipeline to get the (iterative) training going:  
```
nextflow run ../nf/main.nf \
	--outdir $PWD \
	--loci "../data/alignments/full_loci/*.faa" \
	--taxa_list nitrospinota.taxa \
	--n_training_loci 100
```  

i4 iterations for training completed under 14 hours with 4 cores and < 2GB RSS.

### Testing  

Moved to Dropbox because lfs cp exceeded.  

```
cd ~/Dropbox/gtdb/02_working/2306_nitrospinota/05_manual_train
iqtree2 -seed 1 -T 8 -m MFP -pre test_mset_28existing \
	-S ../03_subset_loci/nitrospinota/testing_loci/ \
	-mset "${estimated_Q},Blosum62,cpREV,Dayhoff,DCMut,FLAVI,FLU
,HIVb,HIVw,JTT,JTTDCMut,LG,mtART,mtMAM,mtREV,mtZOA,mtMet,mtVer,mtInv
,PMB,Q.bird,Q.insect,Q.mammal,Q.pfam,Q.plant,Q.yeast,rtREV,VT,WAG"
```  

Interestingly, $Q^{NEW}$ was the best model for 17/20 loci. The remaining loci fit LG, Q.plant and Q.yeast best.  

Revert back to separate testing of existing models vs newly estimated model. This allows for comparison of locus trees between old and new models.  

```  
cd ~/Dropbox/gtdb/02_working/2306_nitrospinota/05_manual_test  
# existing
iqtree2 -seed 1 -T 8 -m MFP -pre test_existing_only \
	-S ../03_subset_loci/nitrospinota/testing_loci/ \
	-mset "Blosum62,cpREV,Dayhoff,DCMut,FLAVI,FLU
,HIVb,HIVw,JTT,JTTDCMut,LG,mtART,mtMAM,mtREV,mtZOA,mtMet,mtVer,mtInv
,PMB,Q.bird,Q.insect,Q.mammal,Q.pfam,Q.plant,Q.yeast,rtREV,VT,WAG"

# new 
iqtree2 -seed 1 -T 8 -m MFP -pre test_new \
	-S ../03_subset_loci/nitrospinota/testing_loci/ \
	-mset ../04_Q_train/Q.bac_locus_i4
```

### Outputs  

#### Training  
Fill `output.Rmd`  

**BIC**  
```
../scripts/cat_bic.sh 04_Q_train/nitrospinota/
```

**IQ-TREE filtering**  
```
../scripts/training_iqtree_filter.sh 04_Q_train/nitrospinota/i4.GTR20.log > training_stats.txt
```

#### Testing  

Parse outputs for separate existing and QNew models:  
```
../scripts/testing_parse_mf.sh test_existing_only.iqtree > mf_existing.txt
../scripts/testing_parse_mf.sh test_new.iqtree > mf_new.txt
../scripts/testing_parse_sub.sh test_existing_only.iqtree > sub_existing.txt
../scripts/testing_parse_sub.sh test_new.iqtree > sub_new.txt
../scripts/testing_parse_ml_tree.sh test_existing_only.iqtree > tree_existing.txt
../scripts/testing_parse_ml_tree.sh test_new.iqtree > tree_new.txt
```  

## Constrained per-locus trees  

### Data filtering  
What happens if the topology is fixed according to the GTDB reference tree (r207)?  

First remove all empty sequences, because IQ-TREE will remove them anyway.
```
cd /home/frederickjaya/Dropbox/gtdb/02_working/2306_constrained_nitrospinota/01_remove_empties
for i in ../../2306_nitrospinota/00_subset_taxa/nitrospinota/*; do 
	~/GitHub/gtdb_trees/scripts/remove_empties.py $i; 
done 
```

Now prune trees for each locus so that each tip is present in the locus alignment:  
```
# Get taxa lists
for i in 01_remove_empties/*; do
	grep ">" $i | sed 's/^>//' > 02_taxa_lists/`basename $i`
done

# Prune trees
for i in ../02_taxa_lists/*; do
	~/GitHub/gtdb_trees/scripts/get_subtree.py ~/GitHub/gtdb_trees/scripts/get_subtree.py ~/GitHub/gtdb_trees/data/trees/gtdb_r207_bac120_unscaled.decorated.tree $i
done
```  


