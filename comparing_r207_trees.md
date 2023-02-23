# Comparing trees for r207

As we get trees for r207, we need to evaluate their likelihoods. Since the primary interest is the topology here, we'll optimise the branch lengths of the tree here too.

Based on analyses [here](https://github.com/fredjaya/gtdb_trees/blob/main/raxml_iqtree.md), we'll use the LG+R8 model for the reduced alignment.

We can *try* to optimise the parameters of that model, or we can fix them to those estimated on a parsimony tree. It will be interesting to see the difference.

The parameters optimised on the parsimony tree are:

`LG+R8{0.310018/0.131557/0.539684/1.181882/0.818461/1.760518/2.631203/4.214275}{0.186522/0.118450/0.176177/0.149001/0.161811/0.101324/0.066409/0.040304}`

We can also try to look at the likehood on the full alignment, though this will be a challenge I expect.

Methods are below. Results come first

## Results

The ID just lets you look up the relevant methods below. 

| ID | Tree                   | Alignment | Model            | Time (m:s) | Memory | lnL        | BIC       | deltaBIC  |                                                                          
| 01 | r207_original          | reduced   | LG+R8 fixed      | Time (m:s) | Memory | lnL        | BIC       | deltaBIC  |                                                                          


## Methods

### r207 original tree plan

First we have to clean the tree to remove labels that raxml doesn't like:

```
sed "s/'[^']*'//g" gtdb_r207_bac120_unscaled.decorated.tree > r207_original_clean.tree
```

Now we'll try the following analyses:

1. Fixed LG+R8 model, reduced alignment
2. Optimised LG+R8 model, reduced alignment
3. Fixed LG+R8 model, big alignment 
4. Optimised LG+R8 model, big alignment 

For step 4 I suspect I'll need to optimise the model on a reduced taxon set. This should be possible to do by selecting 10, 100, 200, 500, 1000, 2000, 5000 taxa on the big alignment, optimising LG+R8 parameters on each, and seeing how much they change. As long as the parameters stabilise at some level I think it's legit to then fix them.

### ID 01

```
/usr/bin/time -o 01.txt -v raxml-ng --msa ../gtdb_r207_bac120_concatenated.faa --model LG+R8{0.310018/0.131557/0.539684/1.181882/0.818461/1.760518/2.631203/4.214275}{0.186522/0.118450/0.176177/0.149001/0.161811/0.101324/0
.066409/0.040304} --threads 16 --force perf_threads --tree r207_original_clean.tree --opt-branches on --evaluate --lh-epsilon 0.1  --prefix 01
```
