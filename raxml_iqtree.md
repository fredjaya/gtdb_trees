# RAxML and IQ-TREE analyses

This is just to keep some notes on what works and what doesn't with RAxML and IQ-TREE.

## Standard analyses, no starting tree

The obvious thing to try is to just put the 66K reduced alignment in with a simple model, and see what happens. I don't have high hopes here, but let's see. 

### RAxML
```
/usr/bin/time -o mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG --threads 32 --tree pars{1} --spr-radius 5
```

I set the SPR radius to something small, in the hopes of keeping it as fast as possible... No free model parameters either.

Gets an MP starting tree after ~15 hours. Then takes a loooong time to try and do any SPRs. I suspect this is wildly impractical!

### IQ-TREE

```
/usr/bin/time -o mem.txt -v iqtree2 -s gtdb_r207_bac120_concatenated.faa -m LG -fast -nt 32 -v 
```

Segmentation fault because it tries to build a NJ tree, and it can't with more than 64K sequences.

## Analyses with a starting tree

Let's try again, but using the MP starting tree from the first RAxML run as a starting tree

### RAxML

```
/usr/bin/time -o mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG --threads 32 --tree gtdb_r207_bac120_concatenated.faa.raxml_parsimony.tree --spr-radius 5
```

### IQ-TREE

```
/usr/bin/time -o mem.txt -v iqtree2 -s gtdb_r207_bac120_concatenated.faa -m LG -fast -nt 32 -t gtdb_r207_bac120_concatenated.faa.raxml_parsimony.tree -v 
```

## Just optimising the tree branch lengths

What if we only want to optimise the branch lengths of the tree? Let's try both with an epsilon of 1.0 likelihood units. (It's usually a lot lower, but I raised it to try and speed things up...)

```
/usr/bin/time -o mem.txt -v iqtree2 -s gtdb_r207_bac120_concatenated.faa -m LG -fast -nt 32 -te gtdb_r207_bac120_concatenated.faa.raxml_parsimony.tree -v --epsilon 1.0
/usr/bin/time -o mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG --threads 32 --tree gtdb_r207_bac120_concatenated.faa.raxml_parsimony.tree --evaluate --lh-epsilon 1.0
```

Then let's try again with epsilon 0.1

```
/usr/bin/time -o mem.txt -v iqtree2 -s gtdb_r207_bac120_concatenated.faa -m LG -fast -nt 32 -te gtdb_r207_bac120_concatenated.faa.raxml_parsimony.tree -v --epsilon 0.1
/usr/bin/time -o mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG --threads 32 --tree gtdb_r207_bac120_concatenated.faa.raxml_parsimony.tree --evaluate --lh-epsilon 0.1
```
This was informative. 

| What             | IQ-TREE (eps 0.1) | IQ-TREE (eps 1.0) | RAxML (eps 0.1)    | RAxML (eps 1.0)   | 
| -------          | ----------------- | ----------------- | ----------------- | -----------------  | 
| Wall time        | 13:27:56          |                   | 0:6:41            | 0:6:12             | 
| LnL              | -138894945.73     |                   | -138894945.42     | -138894945.42      | 
| Efficiency       | 15%               |                   | 74%               | 72%                | 
| Max Mem          | 54.9 Gb           |                   | 47.4 Gb           | 47.4 Gb            | 

So, RAxML is certainly a *lot* quicker and a little more memory efficient. 

Let's see if we can use RAxML for model selection too. 

# Model selection on the MP tree

To do model selection, we need a tree. The MP tree won't be great, but it will be better than nothing. Let's see how far we can push models in RAxML.          
# Rate distribution

RAxML has a few options for models, here are the obvious things to try. I'll switch off branch length optimisation for all of these, to isolate the time just for each model optimisation.

I'll use the brlen optimised tree from RAxML above as the input tree with fixed branch lengths.

* LG (really this just measures overheads, because there are no parameters to tune)
* LG+G
* LG+I+G (+I seems crazy here, because there are no constant sites, but still)
* LG+F
* LG+F+G
* LG+F+I+G

Here are the commandlines:

```
/usr/bin/time -o LGmem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG --threads 32 --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  -—prefix LG
/usr/bin/time -o LGGmem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+G --threads 32 --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  -—prefix LGG
/usr/bin/time -o LGIGmem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+I+G --threads 32 --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  -—prefix LGIG
/usr/bin/time -o LGFmem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+F --threads 32 --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  -—prefix LGF
/usr/bin/time -o LGFGmem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+F+G --threads 32 --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  -—prefix LGFG
/usr/bin/time -o LGFIGmem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+F+I+G --threads 32 --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  -—prefix LGFIG
```


| Model  | Wall Time | Memory | lnL | AIC | BIC |
|------- |-----------|--------|-----|-----|-----|
|LG      ||||||
|LG+G    ||||||
|LG+I+G  ||||||
|LG+F    ||||||
|LG+F+G  ||||||
|LG+F+I+G||||||
