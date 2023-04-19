#!/bin/bash
set -e

IQTREE=/home/frederickjaya/Downloads/iqtree-2.2.3.hmmster-Linux/bin/iqtree2
LOCI_DIR=/home/frederickjaya/Dropbox/gtdb/01_data/gtdb_r207_full_concat
seed=1
PRE=`pwd`/train60_rep1/50/

time $IQTREE -seed $seed -T 8 -S $PRE/train -mset LG,WAG,JTT -cmax 4 -pre $PRE
