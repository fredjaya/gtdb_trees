#!/usr/bin/bash

echo "Iteration BIC" > bic_per_iter.txt
for i in $1*.GTR20.iqtree; do
	iteration=$(basename "$i" .GTR20.iqtree | sed 's/i//')
	bic=$(grep -oP '(?<=\(BIC\) score: )\d+\.\d+' "$i")
	echo "$iteration" "$bic" >> bic_per_iter.txt
done
