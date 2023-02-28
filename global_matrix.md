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

I'll use a starting tree too, since I know this will be painful (if it's possible at all) for poor IQ-TREE...

We'll start with the r207 tree from before...

```
sed "s/'[^']*'//g" gtdb_r207_bac120_unscaled.decorated.tree > gtdb_r207_bac120_unscaled.clean.tree 
```

Now we run step 1 in IQ-TREE, to get the trees. I included the Q.yeast matrix because that performed well in other analyses of this data.

```
iqtree2 -seed 1 -T 32 -S alignments/train -mset LG,WAG,JTT,Q.yeast -cmax 4 -pre bacteria_train -t gtdb_r207_bac120_unscaled.clean.tree 
```
