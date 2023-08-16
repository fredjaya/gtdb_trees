# global_test  

**Goal: Get a working pipeline for estimating bacterial matrices.**

## 1. Subsetting taxa  

Not possible running 60k taxa, so first choose *k* taxa according to some criteria.  

**Phylogenetic distant taxa**  
`/scripts/subset_loci_phydist.sh` selects the *k* most divergent taxa from a pre-inferred tree. Useful for global Q, or choosing representative taxa in a subset.  

**Nested taxa**  
Alternatively, explore the impact of estimating Qs for each taxonomic rank e.g. **Aquaficota** phyla --> genus level.  

## 2. Subsetting loci  

Next, loci need to be separated for training and testing.  

**Random sampling**  
`/scripts/test_train.sh` chooses *l* loci at random.  

**Maximising quality loci**  
Maximise the choice of quality training loci, and reserve a minimum of 20(/120) testing loci.  

Use AliStat to check alignment completeness:  
```
alistat <.fa> 6
```

## 3. Estimating a reversible Q matrix

For this example, 60 training loci (50%) with 50 most phylogenetically distant global taxa. Full dataset. The pipeline below is now represented in `/scripts/estimate_q.py`

**Infer a separate tree for each loci with rev model**  

```
time iqtree2 -seed 1 -T 8 -S `pwd`/train60_rep1/50/train -mset LG,WAG,JTT -cmax 4
```

real    14m52.878s 
user    115m12.347s
sys     0m20.310s  

BIC: 2308388.1399
Frequency of best models:
```
31 LG+I
11 LG+G4
10 LG+F+I
 4 LG+F+R4
 3 LG+R4
 1 LG+F+R3
```

**Estimating a joint rev matrix**  

```
time iqtree2 -seed 1 -T 8 -S train.best_scheme.nex -te train.treefile --model-joint GTR20+FO --init-model LG -pre train.GTR20
```  

real    40m33.884s 
user    319m28.287s
sys     0m6.596s   

```
grep -A 22 "can be used as input for IQ-TREE" train.GTR20.iqtree | tail -n 21 > Q.bac_locus
grep "BIC" | sed 's/^.*: //' #2302557.3857
```

**Repeat estimation - 2nd iteration**  

```
time iqtree2 -seed 1 -T 8 -S `pwd`/train60_rep1/50/train -mset Q.bac_loci -cmax 4 -pre train_i2
```

real    14m15.098s 
user    111m36.695s
sys     0m21.023s  

**MOST OF THE BEST FITTING MODELS ARE +R4 or +G4 here**: bump up `-cmax` and add +I etc.  

New matrix:  
```
time iqtree2 -seed 1 -T 8 -S train_i2.best_scheme.nex -te train_i2.treefile --model-joint GTR20+FO --init-model Q.bac_locus -pre train_i2.GTR20
grep -A 22 "can be used as input for IQ-TREE" train_i2.GTR20.iqtree | tail -n 21 > Q.bac_locus_i2
```  

real    36m31.287s 
user    286m51.970s
sys     0m3.864s   

BIC: 2302000.4810 (< 2302557.3857. Continue)  

**Repeat estimation - 3rd iteration**  

```
mkdir i3
time iqtree2 -seed 1 -T 8 -S train -mset Q.bac_locus_i2 -cmax 4 -pre i3/train_i3
time iqtree2 -seed 1 -T 8 -S i3/train_i3.best_scheme.nex -te i3/train_i3.treefile --model-joint GTR20+FO --init-model i2/Q.bac_locus_i2 -pre i2/train_i2.GTR20
grep -A 22 "can be used as input for IQ-TREE" train_i3.GTR20.iqtree | tail -n 21 > Q.bac_locus_i3
```

real    20m0.915s   
user    146m16.382s 
sys     0m22.984s   

real    43m33.348s 
user    341m57.831s
sys     0m13.122s  

BIC: 2301964.9180 (< 2301964.9180)  
Continue.  

**Repeat estimation - 4th iteration**  

```
mkdir i4
time iqtree2 -seed 1 -T 8 -S train -mset Q.bac_locus_i3 -cmax 4 -pre i4/train_i4
time iqtree2 -seed 1 -T 8 -S i4/train_i4.best_scheme.nex -te i4/train_i4.treefile --model-joint GTR20+FO --init-model i3/Q.bac_locus_i2 -pre i3/train_i3.GTR20
grep -A 22 "can be used as input for IQ-TREE" train_i3.GTR20.iqtree | tail -n 21 > Q.bac_locus_i3
```

real    20m13.678s 
user    154m24.423s
sys     0m23.054s  

real    39m51.939s 
user    310m14.192s
sys     0m4.029s   

BIC: 2301952.8499 (< 2302557.3857)  
Continue.  

**Repeat estimation - 5th iteration**  

```
mkdir i5
time iqtree2 -seed 1 -T 8 -S train -mset Q.bac_locus_i3 -cmax 4 -pre i4/train_i4
time iqtree2 -seed 1 -T 8 -S i5/train_i5.best_scheme.nex -te i5/train_i5.treefile --model-joint GTR20+FO --init-model i4/Q.bac_locus_i4 -pre i5/train_i5.GTR20
```

BIC: 2301988.0892.

**Stop!** i4 is best Q.  

## 4. Testing  

### IQ-TREE

**1. 60 training loci**  

See how `Q.bac_locus_i4` performs against other pre-defined Q matrices.  
```
mkdir test_analysis
# With estimated Q
time iqtree2 -seed 1 -T 8 -S test -mset i4/Q.bac_locus_i4 -pre test_analysis/Q.bac_locus_i4
# With predefined models
time iqtree2 -seed 1 -T 8 -S test -pre test_analysis/predefined  
```

Q.bac_locus_i4 BIC: 2672227.1299
Predefined BIC: 2680521.6803 Models: LG,Q.pfam,Q.yeast with varying +F,+I,+R,+G

**2. Reduced data (fixed tree)**
```
cd ~/Dropbox/gtdb/02_working/2304_global_test/train60_rep1/50
mkdir test_reduced
# With existing models  
time iqtree2 -seed 1 -T 8 -s gtdb_r207_bac120_concatenated.faa -pre existing/existing
# With estimated_Q
time iqtree2 -seed 1 -T 8 -s gtdb_r207_bac120_concatenated.faa -pre Q.bac_locus_i4/Q.bac_locus_i4 -mset Q.bac_locus_i4 -te gtdb_r207_bac120_unscaled.decorated.tree
```

`ERROR: Not enough memory, allocation of 201557241632 bytes failed (bad_alloc)` lol...  FastTree it is!  

### FastTree  

**1. 60 testing loci**  

#### On reduced concatenated data


```
# gtdb tree uses wag  
FastTree -wag -gamma -nome -mllen -fastest -intree ~/Dropbox/gtdb/01_data/gtdb_r207_bac_120_figtree.tre -log wag_reduced.log ~/Dropbox/gtdb/00_raw_data/r207/gtdb_r207_bac120_concatenated.faa > wag_reduced.ftlen
```

**Estimated Q**
```
cd ~/Dropbox/gtdb/02_working/2304_global_test/train60_rep1/50/test_reduced/ft_q


```
