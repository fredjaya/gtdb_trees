# Estimating a Q matrix for bacteria.

I don't know if this will work, let's see. We'll start with the 120 alignments of individual loci, and follow the instructions here: http://www.iqtree.org/doc/Estimating-amino-acid-substitution-models


# Split the data

I'll split it into 100 training and 20 test loci. The code below is when working in a folder with all those alignments.

```
mkdir train
mkdir test

# this just chooses 20 files at random
ls |sort -R |tail -20 |while read file; do
  mv $file test/$file
done

mv gtdb* train/ 
```

# Subset the alignments

Initial analyses show that we have no hope of estimating a matrix for trees of 66K taxa. So the approach has to be to subset each alignment to a subset of e.g. 1K taxa, and go from there. 

Here's a plan:

1. Remove all taxa with more than 20% gaps (have a look at a bunch of the alignments first, and look at what a reasonable number might be).
2. From what's left, choose the 10K taxa with the most PD from the global tree
3. From those, randomly choose 1K taxa

This keeps a lot of randomness in the selection, but step 2 also ensrues that we don't get too biased by taxon sampling either. Also, the proportion of gaps, the number of initial taxa (step 2) and the number of final taxa (step 3) can all be adjusted at will. We want the datasets as large as possible to estimate the matrix, but bearing in mind computational constraints at each step.

Additinoally, I think we can just re-do this process for *any* sub-clade by introducing an extra filtering step:

0. Remove all taxa not in the named sub-clade

Then we have a very flexible approach to estimating matrices for sub-clades.


# Run the Q matrix estimation

# Test the Q matrix on the 20 test alignments

For this part one could subset the alignments similarly to above, or perhaps better to just choose random sets of ~100 taxa from each alignment, and fit the models to those. E.g. for each alignment you could choose 100 non-overlapping sets of 100 taxa, and then do the model selection on those. They're not all independent (a lot will contain the deeper branches) but it's still a sensible way to use the data to good effect.

Some other ideas for model comparison:

1. Fix the tree to r207 and ask which model fits better for each locus in raxml-ng or IQ-TREE
2. As for 1 but reoptimise the tree under each model in FastTree, using r207 as the starting tree. 
3. As for 2 but with the 20 loci concatentated
4. As for 2 but with all 120 loci concatenated
5. Tests of topologies in IQ-TREE for the trees from 3 and 4
