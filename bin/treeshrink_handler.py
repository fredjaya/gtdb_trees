#!/usr/bin/env python3
"""
The goal here is to deal with a treeshrink error when, I think, there are too
few tips in a tree. When automatically trying to solve for k, k==1 where k>2 
for the density function to work. A better solution would be to add a check for 
k>2 prior to run_treeshrink.py 
"""

import sys
import os
import subprocess

pruned_tree = sys.argv[1]
group_name = sys.argv[2]

error_messages = ["Error in read.table(datafile) : no lines available in input",
        "need at least 2 points to select a bandwidth automatically"]
cmd = ["run_treeshrink.py", "--tree", pruned_tree, "--outprefix", group_name]
result = subprocess.run(cmd, capture_output=True, text=True)
if any([e in result.stderr for e in error_messages]):
    # This is gross, but required for nextflow IO continuity
    out_name = f"{group_name}_unshrunk.tree"
    print(out_name)
    with open(pruned_tree, 'r') as in_tree, open(out_name, 'w') as out_tree:
        for line in in_tree:
            out_tree.write(line)
#else:
#    shrunk = os.stat(f"{group_name}.txt").st_size > 0
#    print(shrunk)
