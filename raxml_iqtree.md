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

So, this took ~52 hours, and used ~7 processors on average (so an efficiency of 22%). It used 55Gb of memory.

It does look like IQ-TREE managed to optimise the tree a bit too:

Initial lnL: -138582337.79
Final lnL:   -138581893.07

So, this is encouraging. 

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
| Wall time        | 13:27:56          | 12:35:51          | 0:6:41            | 0:6:12             | 
| LnL              | -138894945.73     | -138894945.75     | -138894945.42     | -138894945.42      | 
| Efficiency       | 15%               | 15%               | 74%               | 72%                | 
| Max Mem          | 54.9 Gb           | 54.9 Gb           | 47.4 Gb           | 47.4 Gb            | 

So, RAxML is certainly a *lot* quicker and a little more memory efficient. 

Let's see if we can use RAxML for model selection too. 

# Model selection on the MP tree

To do model selection, we need a tree. The MP tree won't be great, but it will be better than nothing. Let's see how far we can push models in RAxML.          
# Rate distribution

RAxML has a few options for models, here are the obvious things to try. I'll switch off branch length optimisation for all of these, to isolate the time just for each model optimisation.

I'll use the brlen optimised tree from RAxML above as the input tree with fixed branch lengths.

* LG (really this just measures overheads, because there are no parameters to tune)

Rate distributions:

* nothing
* +G
* +I+G (empirical I esitmate)
* +IO+G (ml I estimate)
* +R2
* +R3 
* +R4
* +I+R2
* +I+R3
* +I+R4
* +IO+R2
* +IO+R3
* +IO+R4

Amino acid frequencies:

* from LG
* +F (empirical)
* +FO (ml estimates)

Here are the commandlines for all 39 combinations (in a randomish order as I learned more about RAxML-ng options...)

```
/usr/bin/time -o LGmem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LG
/usr/bin/time -o LGGmem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+G --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGG
/usr/bin/time -o LGIGmem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+I+G --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGIG
/usr/bin/time -o LGIOGmem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+IO+G --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGIOG

/usr/bin/time -o LGFmem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+F --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGF
/usr/bin/time -o LGFGmem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+F+G --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFG
/usr/bin/time -o LGFIGmem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+F+I+G --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFIG
/usr/bin/time -o LGFIOGmem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+F+IO+G --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFIOG



/usr/bin/time -o LGR2mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+R2 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGR2
/usr/bin/time -o LGR3mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+R3 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGR3
/usr/bin/time -o LGR4mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+R4 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGR4

/usr/bin/time -o LGIR2mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+I+R2 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGIR2
/usr/bin/time -o LGIR3mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+I+R3 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGIR3
/usr/bin/time -o LGIR4mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+I+R4 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGIR4


/usr/bin/time -o LGIOR2mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+IO+R2 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGIOR2
/usr/bin/time -o LGIOR3mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+IO+R3 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGIOR3
/usr/bin/time -o LGIOR4mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+IO+R4 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGIOR4


/usr/bin/time -o LGFR2mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+F+R2 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFR2
/usr/bin/time -o LGFR3mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+F+R3 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFR3
/usr/bin/time -o LGFR4mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+F+R4 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFR4

/usr/bin/time -o LGFIR2mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+F+I+R2 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFIR2
/usr/bin/time -o LGFIR3mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+F+I+R3 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFIR3
/usr/bin/time -o LGFIR4mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+F+I+R4 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFIR4


/usr/bin/time -o LGFIOR2mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+F+IO+R2 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFIOR2
/usr/bin/time -o LGFIOR3mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+F+IO+R3 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFIOR3
/usr/bin/time -o LGFIOR4mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+F+IO+R4 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFIOR4


/usr/bin/time -o LGFOmem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+FO --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFO
/usr/bin/time -o LGFOGmem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+FO+G --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFOG
/usr/bin/time -o LGFOIGmem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+FO+I+G --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFOIG
/usr/bin/time -o LGFOIOGmem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+FO+IO+G --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFOIOG


/usr/bin/time -o LGFOR2mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+FO+R2 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFOR2
/usr/bin/time -o LGFOR3mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+FO+R3 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFOR3
/usr/bin/time -o LGFOR4mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+FO+R4 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFOR4


/usr/bin/time -o LGFOIR2mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+FO+I+R2 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFOIR2
/usr/bin/time -o LGFOIR3mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+FO+I+R3 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFOIR3
/usr/bin/time -o LGFOIR4mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+FO+I+R4 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFOIR4


/usr/bin/time -o LGFOIOR2mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+FO+IO+R2 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFOIOR2
/usr/bin/time -o LGFOIOR3mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+FO+IO+R3 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFOIOR3
/usr/bin/time -o LGFOIOR4mem.txt -v raxml-ng --msa gtdb_r207_bac120_concatenated.faa --model LG+FO+IO+R4 --threads 16 --force perf_threads --tree gtdb_r207_bac120_concatenated.faa.raxml.bestTree --opt-branches off --evaluate --lh-epsilon 0.1  --prefix LGFOIOR4
```

Delta BIC is compared to the best model so far. 
Wall time is m:s
Memory is in GB

| Model       | Time (m:s) | Memory | lnL        | BIC       | deltaBIC  | params                                                                                                                                                                                                                |
|-------------|------------|--------|------------|-----------|-----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| LG          | 2:00       | 35     | -138894945 | 278851848 | -15872163 | NA                                                                                                                                                                                                                    |
| LG+G        | 10:32      | 122    | -131342037 | 263746041 | -766356   | LG+G4m{0.928691}                                                                                                                                                                                                      |
| LG+I+G      | 32:18      | 122    | -130970438 | 263002851 | -23166    | LG+IU{0.356239}+G4m{1.185920}                                                                                                                                                                                         |
| LG+IO+G     | 33:41      | 122    | -130970438 | 263002851 | -23166    | LG+IU{0.356239}+G4m{1.185920}                                                                                                                                                                                         |
| LG+F        | 1:58       | 35     | -139310868 | 279683856 | -16704171 |    Base frequencies (empirical): 0.097978 0.055944 0.031043 0.050875 0.008364 0.030803 0.069143 0.057151 0.018318 0.080991 0.104304 0.067822 0.024028 0.032508 0.035765 0.054730 0.051257 0.006756 0.024449 0.097773  |
| LG+F+G      | 10:40      | 122    | -131483774 | 264029676 | -1049991  | LG+FC+G4m{0.854565}; aa freqs as for LG+F                                                                                                                                                                             |
| LG+F+I+G    | 31:33      | 122    | -130981085 | 263024306 | -44621    | LG+FC+IU{0.396633}+G4m{1.139195}                                                                                                                                                                                      |
| LG+F+IO+G   | 30:50      | 122    | -130981085 | 263024306 | -44621    | LG+FC+IU{0.396633}+G4m{1.139195}                                                                                                                                                                                      |
| LG+R2       | 36:41      | 64     | -133141864 | 267345702 | -4366017  | LG+R2{0.477258/1.928660}{0.639836/0.360164}                                                                                                                                                                           |
| LG+R3       | 79:01      | 93     | -131520921 | 264103834 | -1124149  | LG+R3{0.308202/0.989746/2.712386}{0.411955/0.419107/0.168938}                                                                                                                                                         |
| LG+R4       | 113:40     | 122    | -130958838 | 262979685 | 0         | LG+R4{0.235731/0.657483/1.369952/3.119759}{0.295838/0.332110/0.256490/0.115562}                                                                                                                                       |
| LG+I+R2     | 30:58      | 64     | -133143219 | 267348421 | -4368736  | LG+IU{0.235932}+R2{0.477263/1.928575}{0.639818/0.360182}                                                                                                                                                              |
| LG+I+R3     | 67:33      | 93     | -131523019 | 264108039 | -1128354  | LG+IU{0.340747}+R3{0.308186/0.989732/2.712115}{0.411968/0.419055/0.168977}                                                                                                                                            |
| LG+I+R4     |  NA        | NA     | NA         | NA        | NA        | This analysis hangs, no idea why                                                                                                                                                                                      |
| LG+IO+R2    |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+IO+R3    |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+IO+R4    |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+F+R2     |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+F+R3     |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+F+R4     |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+F+I+R2   |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+F+I+R3   |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+F+I+R4   |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+F+IO+R2  |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+F+IO+R3  |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+F+IO+R4  |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+FO       |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+FO+G     |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+FO+I+G   |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+FO+IO+G  |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+FO+I+R2  |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+FO+I+R3  |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+FO+I+R4  |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+FO+IO+R2 |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+FO+IO+R3 |            |        |            |           |           |                                                                                                                                                                                                                       |
| LG+FO+IO+R4 |            |        |            |           |           |                                                                                                                                                                                                                       |

No real surprises here. I guess the +I+G models are better because the +I frees the gamma distribution to better fit what's left (even though there are no constant sites).

It's a bit odd that the +F models don't work. I guess empirical frequencies are no good. The +FO models should get better likelihoods, but likely at a prohibitive cost.
