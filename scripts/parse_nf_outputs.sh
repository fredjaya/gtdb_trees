#!/bin/bash  

# Takes in a phylum directory written by nf as input. It will then find
# the necessary files within it to make it easy to input to Rmd
TAXA=$1

mkdir -p output/${PHYLUM_DIR}

# Save AliStat summary
cp -L ${PHYLUM_DIR}/01_alistat/*_alistats.csv output/${PHYLUM_DIR}/alistats.csv

# Identify optimal iteration
BEST_ITER=`ls ${PHYLUM_DIR}/04_Q_train/Q.bac_locus_i* | sort | tail -2 | head -1 | sed 's/^.*_i//'`

# Get BIC per iteration
ITER=0
echo "Iteration BIC" > output/${PHYLUM_DIR}/bic_per_iter.txt
for i in `ls ${PHYLUM_DIR}/04_Q_train/i*.GTR20.iqtree`; do
	ITER=$((ITER+1))
	echo ${ITER} `grep "(BIC)" $i | sed 's/^.*: //'`
done >> output/${PHYLUM_DIR}/bic_per_iter.txt

# Get test_loci performance of estimated and existing Qs 
grep -A23 "List of best-fit models per partition" \
	${PHYLUM_DIR}/05_Q_test_loci/existing_Q.iqtree | head -23 | tail -21 \
	> output/${PHYLUM_DIR}/existing_models.txt
grep -A23 "List of best-fit models per partition" \
	${PHYLUM_DIR}/05_Q_test_loci/Q.bac_locus*.iqtree | head -23 | tail -21 \
	> output/${PHYLUM_DIR}/unconstrained_models.txt

# Get tree lengths
grep -A23 "Topology-unlinked partition model with separate substitution models and separate rates across sites" \
	${PHYLUM_DIR}/05_Q_test_loci/existing_Q.iqtree | head -23 | tail -21 \
	> output/${PHYLUM_DIR}/existing_substitutions.txt

grep -A23 "Topology-unlinked partition model with separate substitution models and separate rates across sites" \
	${PHYLUM_DIR}/05_Q_test_loci/Q.bac_locus*.iqtree | head -23 | tail -21 \
	> output/${PHYLUM_DIR}/unconstrained_substitutions.txt
