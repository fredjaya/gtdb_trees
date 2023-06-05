#!/usr/bin/bash

# parse .iqtree for lnL, BIC and tree lengths.
# Run on testing outputs of existing vs. QNew to view impact of new model.

grep -A 22 -P "List of best-fit models per partition" $1 | sed '1,2d'
