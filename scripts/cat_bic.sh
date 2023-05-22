#!/usr/bin/bash

RE="Bayesian information criterion (BIC) score: "
for i in i*; do
	echo $i `grep "$RE" $i/*.GTR20.iqtree` | \
		sed -e s/"$RE"// -e s/^i//
	done | sort -h
