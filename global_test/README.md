# global_test  

**Goal:** get a working pipeline for estimating bacterial matrices.  

**0. Subset loci according to phylogenetic distance**  

(Add subset scripts here)  

60 training loci (50%) with 50 most phylogenetically distant global taxa. Full dataset.  

**1. Infer a separate tree for each loci with rev model**  

```
time iqtree2 -seed 1 -T 8 -S `pwd`/train60_rep1/50/train -mset LG,WAG,JTT -cmax 4
```

real    14m52.878s 
user    115m12.347s
sys     0m20.310s  

Frequency of best models:
```
31 LG+I
11 LG+G4
10 LG+F+I
 4 LG+F+R4
 3 LG+R4
 1 LG+F+R3
```

**2. Estimating a joint rev matrix**  

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

**3. Repeat estimation (from 1.)**  

```
time iqtree2 -seed 1 -T 8 -S `pwd`/train60_rep1/50/train -mset Q.bac_loci -cmax 4 -pre train_i2
```
