# Re-evaluate the main firmicutes sub-clade

One thing that's clear from the previous analyses is that the models in FastTree won't be very good for these data (not to mention that you can only analyse a fraction of the data anyway.

Another, likely better, option is to split the tree into sub-clades, and optimise these more thoroughly in better software with better models. 

So, I picked out one clade which seemed to have lots of rate variation in the r207 tree - the firmicutes clade. It has 4216 taxa.

The idea is then to estimate the best possible tree for that clade, and compare it to the sub-tree for that clade in the r207 tree.


# Extracting the clade

I selected the clade in Dendroscope, cleaned up the genome list, and then:

```
faSomeRecords r207_reduced.fa firmicutes.txt r207_reduced_firmicutes.fa
faSomeRecords r207_full.fa firmicutes.txt r207_full_firmicutes.fa
```

Now we extract that same clade from the tree in Dendroscope, and clean up the labels like so:

```
sed "s/'[^']*'//g" firmicutes_r207.tree > firmicutes_r207_clean.tree
```

Then I manually removed the root branch from the tree.

# Naive analyses

Let's start simple - model testing with IQ-TREE on the reduced and full length alignments, and a tree search in raxml-ng on the full length alignment.

```
/usr/bin/time -o raxml_LGR4.txt -v raxml-ng --msa r207_full_firmicutes.fa --model LG+R4 --threads 64 --tree firmicutes_r207_clean.tree 

/usr/bin/time -o iqtree.txt -v iqtree -s r207_full_firmicutes.fa -m TEST -madd LG4M,LG4X,C10,C20,Q.bird,NQ.bird,Q.insect,NQ.insect,Q.mammal,NQ.mammal,Q.pfam,NQ.pfam,Q.plant,NQ.plant,Q.yeast,NQ.yeast -nt 64 -v -t firmicutes_r207_clean.tree -pre iqtree_full

/usr/bin/time -o iqtree.txt -v iqtree -s r207_reduced_firmicutes.fa -m TEST -madd LG4M,LG4X,C10,C20,Q.bird,NQ.bird,Q.insect,NQ.insect,Q.mammal,NQ.mammal,Q.pfam,NQ.pfam,Q.plant,NQ.plant,Q.yeast,NQ.yeast -nt 64 -v -t firmicutes_r207_clean.tree -pre iqtree_reduced


```
