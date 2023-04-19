#!/bin/bash
set -e

IQTREE=/home/frederickjaya/Downloads/iqtree-2.2.3.hmmster-Linux/bin/iqtree2
LOCI_DIR=/home/frederickjaya/Dropbox/gtdb/01_data/gtdb_r207_full_concat
seed=1

time $IQTREE -seed $seed -T 8 \
	-S `pwd`/train60_rep1/50/train.best_scheme.nex \
	-te `pwd`/train60_rep1/50/train.treefile \
	--model-joint GTR20+FO --init-model LG -pre `pwd`/train60_rep1/50/train.GTR20
