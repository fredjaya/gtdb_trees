#!/bin/bash
set -e

IQTREE=/home/frederickjaya/Downloads/iqtree-2.2.3.hmmster-Linux/bin/iqtree2
TREE=/home/frederickjaya/Dropbox/gtdb/00_raw_data/r207/gtdb_r207_bac120_unscaled.decorated.tree
LOCI_DIR=/home/frederickjaya/Dropbox/gtdb/01_data/gtdb_r207_full_concat

for k in {10,50,100,500,1000}; do
	# Subset k taxa with the maximum phylogenetic distance
	mkdir -p k_taxa
	$IQTREE -te $TREE -k $k -pre k_taxa/$k
	# Parse taxa names
	sed '0,/The optimal PD set has/d' k_taxa/${k}.pda | sed '/^$/,$d' > k_taxa/${k}.txt
	# Subset taxa from each loci
	mkdir -p k_loci/$k
	for l in $LOCI_DIR/*.faa; do
		echo $l
		faSomeRecords.py --fasta $l --list k_taxa/${k}.txt --outfile k_loci/$k/`basename $l`
	done
done
