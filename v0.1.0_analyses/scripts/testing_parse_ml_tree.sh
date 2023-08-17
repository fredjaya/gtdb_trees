#!/usr/bin/bash

# parse .iqtree for scores post-tree optimisation  
# Run on testing outputs of existing vs. QNew to view impact of new model.

echo "tree_lnL unconstrained_lnl free_params AIC AICc BIC tree_length_total tree_length_internal"

lnL=$(grep 'Log-likelihood of the tree:' $1 | cut -d' ' -f5)
unconstrained_lnl=$(grep 'Unconstrained log-likelihood' $1 | cut -d' ' -f5)
free_params=$(grep 'Number of free parameters' $1 | cut -d' ' -f9)
AIC=$(grep 'Akaike information criterion (AIC) score:' $1 | cut -d' ' -f6)
AICc=$(grep 'Corrected Akaike information criterion (AICc) score:' $1 | cut -d' ' -f7)
BIC=$(grep 'Bayesian information criterion (BIC) score:' $1 | cut -d' ' -f6)
tree_length_total=$(grep 'Total tree length (sum of branch lengths):' $1 | cut -d' ' -f8)
tree_length_internal=$(grep 'Sum of internal branch lengths:' $1 | cut -d' ' -f6)

echo "$lnL $unconstrained_lnl $free_params $AIC $AICc $BIC $tree_length_total $tree_length_internal"
