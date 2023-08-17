#!/bin/bash  

# Takes in a phylum directory written by nf as input. It will then find
# the necessary files within it to make it easy to input to Rmd
if [ -z "$1" ]; then
	echo "Example usage: parse_nf_outputs.sh p__Myxococcota_treeshrunk/"
fi
TAXA=$1

mkdir -p output/${TAXA}

# Save AliStat summary
cp -L ${TAXA}/01_alistat/*_alistats.csv output/${TAXA}/alistats.csv

# Identify optimal iteration
BEST_ITER=`ls ${TAXA}/04_Q_train/Q.bac_locus_i* | sort | tail -2 | head -1 | sed 's/^.*_i//'`

# Get BIC per iteration
ITER=0
echo "Iteration BIC" > output/${TAXA}/bic_per_iter.txt
for i in `ls ${TAXA}/04_Q_train/i*.GTR20.iqtree`; do
	ITER=$((ITER+1))
	echo ${ITER} `grep "(BIC)" $i | sed 's/^.*: //'`
done >> output/${TAXA}/bic_per_iter.txt

# Get test_loci performance of estimated and existing Qs 
grep -A23 "List of best-fit models per partition" \
	${TAXA}/05_Q_test_loci/existing_Q.iqtree | head -23 | tail -21 \
	> output/${TAXA}/existing_models.txt
grep -A23 "List of best-fit models per partition" \
	${TAXA}/05_Q_test_loci/Q.bac_locus*.iqtree | head -23 | tail -21 \
	> output/${TAXA}/unconstrained_models.txt

# Get tree lengths
grep -A23 "Topology-unlinked partition model with separate substitution models and separate rates across sites" \
	${TAXA}/05_Q_test_loci/existing_Q.iqtree | head -23 | tail -21 \
	> output/${TAXA}/existing_substitutions.txt

grep -A23 "Topology-unlinked partition model with separate substitution models and separate rates across sites" \
	${TAXA}/05_Q_test_loci/Q.bac_locus*.iqtree | head -23 | tail -21 \
	> output/${TAXA}/unconstrained_substitutions.txt
