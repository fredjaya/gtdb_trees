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

