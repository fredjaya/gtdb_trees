#!/usr/bin/bash

# As IQ-TREE does some alignment filtering,
# Extract alignment filtering info in the best iteration of Q training.
grep -A 100 -P "Subset\tType\tSeqs" $1
