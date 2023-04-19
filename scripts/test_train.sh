#!/bin/bash
set -e

n_train=60 # {0.5,0.6,0.7,0.8,0.9} * 120 loci == {60,72,84,96,108}
nrep=1
LOCI_DIR=/home/frederickjaya/Dropbox/gtdb/01_data/gtdb_r207_full_concat
OUT_DIR=train${n_train}_rep${nrep}

# Randomly subset n loci
mkdir $OUT_DIR
ls $LOCI_DIR | sort -R | tail -n $n_train > $OUT_DIR/training_loci.txt

# Use the same subset for all k loci
k=100
for k in {10,50,100,500,1000}; do
	mkdir -p $OUT_DIR/$k/train $OUT_DIR/$k/test
	ln -s `pwd`/k_loci/$k/* $OUT_DIR/$k/

	# Organise training and testing loci
	cat $OUT_DIR/training_loci.txt | \
		xargs -n 1 -I {} sh -c "mv $OUT_DIR/$k/{} $OUT_DIR/$k/train"
	mv $OUT_DIR/$k/*.faa $OUT_DIR/$k/test
done
