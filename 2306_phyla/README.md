# 2306_phyla  

Estimating phylum-specific matrices.  

## To-do  

First pass:  
- [x] Prepare taxa lists for all phyla with >50 taxa  
- [x] Prune reference tree for each phyla   
- [x] Get branch lengths and total tree length  
- [x] Run treeshrink on all phyla  
- [x] ID phyla with shrunk trees  
- [ ] Get branch lengths and total tree lengths for pruned phyla   
- [ ] Identify resource usage vs. BIC across subsets of taxa in a big phyla  

## Taxa lists  
`taxa/ge_50.phyla` - All phyla with 50 or more taxa.  

```  
for taxa in `cat ge_50.phyla`; do
	grep $taxa ../data/gtdb_r207_bac120_curation_taxonomy_tabbed.tsv | \
		cut -f1 > lists/${taxa}.phyla
done
```  

45 taxa remain.  

Make folders for each phyla under `analysis/`:  

## Pruning  

Make trees for each phyla by pruning from the r207 tree.  

```  
for phylum in taxa/lists/*; do
	../scripts/get_subtree.py \
		../data/trees/gtdb_r207_bac120_unscaled.decorated.tree \
		${phylum}
	mv pruned.tree analysis/`basename ${phylum} .phyla`
done
```

## Branch lengths  

**moving everything to /home/frederickjaya/Dropbox/gtdb/02_working/2306_phyla**  

Calculate total tree length and branch length distributions:  
```
for i in analysis/*; do  
	echo $i  
	~/GitHub/gtdb_trees/scripts/tree_length.py $i/pruned.tree > $i/pruned.tree.length
	mv branch_length_histogram $i
done 
```  

Compile tree lengths and manually add to master tsv:  
```
for i in *; do echo $i `cat $i/pruned.tree.length`;done > all_tree_lengths.txt
```  

## Treeshrink  

```
for i in analysis/*; do 
	echo $i
	~/GitHub/TreeShrink/run_treeshrink.py -t $i/pruned.tree > $i/treeshrink.log
done
``` 

Identify the number of taxa dropped for each phyla:  
```
for i in *; do echo $i `grep -oP "\t" $i/analysis/pruned_treeshrink/output.txt | wc -l`; done > n_taxa_dropped_treeshrink.txt
```  

25/45 phyla had taxa removed. 0.09% - 1.59% of taxa were dropped.  

Calculate total tree length and branch length distributions:  
```
for i in analysis/*; do  
	echo $i
	~/GitHub/gtdb_trees/scripts/tree_length.py $i/pruned_treshrink/output.tree > $i/pruned_treeshrink/pruned_treeshrink.tree.length
	mv branch_length_histogram.png $i/pruned_treeshrink
done 
```  

Compile tree lengths and manually add to master tsv:  
```
for i in analysis/*; do echo $i `cat $i/pruned_treeshrink/pruned.tree.length`; done > all_tree_lengths.txt
```  

Tree lengths reduction across phyla ranged from 0.11% - 7.65% of the original length. Phyla Fusobacteriota, Nitrospirota, Synergistota, Dormibacterota underwent the most shrinking (>2%).  


