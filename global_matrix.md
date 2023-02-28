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

Initial analyses show that we have no hope of estimating a matrix for trees of 66K taxa. Also it seems exceptionally dumb to try and do so with loci of ~300 amino acids. So the approach has to be to subset each alignment to a subset of e.g. 1K taxa, and go from there. The alternative is unpalatable, which is to assume all the loci come from one tree. That seems very silly for bacteria. 

Still, we should focus on the 'core' genes in this dataset, because that's what a lot of people use for phylogenetics. So, what can we do?

Here's a plan. The idea is to be able to select a certain number of taxa from each alignment, maximising the quality of the alignment and the number of substitutions we sample.

For each locus

0. Choose a final number of taxa T we can cope with computationally in each alignment. It needs to be large enough to estimate a decent Q matrix across 100 loci (this is an empirical question, of course, so we need to do some testing). Let's say we start with 100, because it's a small number and will make the Q matrix fast. We can increase it later.
1. Keep only the N 'best' taxa in the alignment, for some definition of 'best' (e.g. least gaps and ambiguities, or some other measure of alignment quality). I think ideally we want N to be a lot larger than T. I.e. we want to retain FAR more taxa in the alignment than we actually want to end up with.
2. Fix the global tree, prune to the N taxa left in the alignment, and re-estimate its branch lengths under a sensible model (e.g. LG+G) in raxml-ng.
3. Another QC step - use TreeShrink or something similar to remove any taxa on implausibly long branches.  
4. Now choose some multiple of T (say 5x or 10x) taxa from the tree that represent the maximum amount of branch length (can be done in IQ-TREE very easily with a -k command, ask Minh). This is also known as maximising phylogenetic diversity. The idea here is to get a large tree that respresents almost all of the PD in the original alignment.  
5. From those, randomly choose your T taxa.
6. Just so we know, calculate the tree length of T from the tree estimated in step 2, and compare it to the maximum possible PD you could have got if you only selected T taxa at step 4. This just tells you what proportion of substitutions you're missing by doing it this way.

The benefit of selecting randomly in step 5 is that we don't necessarily want the maximum PD set of T taxa - these could well be the odd ones, on very long branches, with fast evolution.

7. Do some QC on the alignment, e.g. looking at branch lengths adn sitewise measures of saturation. 


## Choosing T

Of course, each step in this method can be changed a lot. But I'd argue the best approach is to make sensible a-priori decisions for most of them, and then just try estimating a few different matrices at different T's. E.g. T = 100, 200, 300, etc. You can then compare the matrices in terms of their actual values (e.g. differences between the Q matrices and Frequency vectors) and their fit to the test data (see below). 

Ultimately I guess we want T to be as large as possible given our computational (and carbon) constraints. But we can empirically look at how stable the matrix is as we increase T - there's no point making it larger than it needs to be.

## Adapting this to build clade-specific matrices

I think we can just adjust this process very easily for *any* sub-clade, by simply altering step 1 in the process above to first remove any taxa not in that sub-clade, and then proceeding in the exact same way for the rest of the pipeline.
 
This allows useful human intervention in the definition of sub-clades.

# Run the Q matrix estimation

Follow instructions for independent loci here: http://www.iqtree.org/doc/Estimating-amino-acid-substitution-models

Note that we should attempt both reversible and non-reversible matrices. 

# Testing the Q matrices 

## On the 20 test alignments

The idea here is just to replicate whatever we did in the QMaker paper. The challenge is that we can't estimate trees for 66K taxa, it's just not possible. So instead I think a sensible approach is to do something like this:

For each test locus:

1. Remove taxa that are >50% gaps (lots of the taxa are 100% gaps)
2. Create ~100 alignmetns from each alignment, where each new alignment contains a randomly-selected (wihtout replacement) set of taxa. Label these 1-100.
3. Compare the models and the trees you infer under them as in the QMaker and NQMaker papers

Because you made 100 sub alignmetns, you essentially get 100 repeat measures of the fit of the models. For example, let's say you take the 20 sub-alignments labelled '1'. This might tell you that the new matrix is the best fit in 15/20. Becuase you have 100 pseudo-replicate alignments, you can repeat this estimate for all 100 sets, and you get a distribution of estimates of this number. So maybe you end up saying that the 95% CIs are 12-19 alignments where the new matrix is better. 

## In other ways

Of course, you should compare the Q matrices adn frequency vectors themselves. And study their entries and what they mean. Look out especially for implausible values.

Some other ideas for model comparison:

1. Fix the tree to r207 and ask which model fits better for each locus in raxml-ng or IQ-TREE
2. As for 1 but reoptimise the tree under each model in FastTree, using r207 as the starting tree. 
3. As for 2 but with the 20 loci concatentated
4. As for 2 but with all 120 loci concatenated
5. Tests of topologies in IQ-TREE for the trees from 3 and 4

Others?
