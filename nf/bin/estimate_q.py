#!/usr/bin/env python3  

import argparse
import subprocess
import os
import re

def run_command(cmd):
    if args.verbose:
        print(cmd, "\n")
    process = subprocess.Popen(cmd, shell=True,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    exit_code = process.returncode
    if exit_code !=0:
        print(stderr, stdout, exit_code)
    return stdout, stderr, exit_code

def grep_iqtree(string, filename):
    index = [ idx for idx, l in enumerate(lines) if string in l ][0]
    with open(filename, 'w') as f:
        # TODO: softcode for single concat tree
        f.writelines([ l.lstrip() for l in lines[index+2:index+22] ])

parser = argparse.ArgumentParser()
parser.add_argument('-l', '--loci', type=str, help='Path to original loci', required=True)
parser.add_argument('-v', '--verbose', action='store_true', help='Print commands', required=False)

args = parser.parse_args()

"""
Python program related
"""
bic_1 = None
bic_0 = None
iteration = 0
    
"""
IQ-TREE related
"""
#TODO: softcode bin path
iqtree_path = "/home/frederickjaya/Downloads/iqtree-2.2.3.hmmster-Linux/bin/iqtree2" 
seed = 1
threads = 4

while bic_0 is None or bic_1 <= bic_0:
    bic_0 = bic_1
    iteration += 1
    print("ITERATION: ", iteration)
    
    best_scheme = f"i{iteration}.best_scheme.nex"
    tree_file = f"i{iteration}.treefile"
    estimated_Q = f"Q.bac_locus_i{iteration-1}"
    mset = estimated_Q
    if iteration == 1:
        mset = "LG,WAG,JTT"
        estimated_Q = "LG"

    #run_command(f"mkdir -p i{iteration}")
    # Construct per-locus trees
    run_command(f"{iqtree_path} -seed {seed} -T {threads} -S {args.loci} \
            -mset {mset} -cmax 4 -pre i{iteration}")
    # Estimate Q-matrix
    run_command(f"{iqtree_path} -seed {seed} -T {threads} -S {best_scheme} -te {tree_file} \
            --model-joint GTR20+FO --init-model {estimated_Q} -pre i{iteration}.GTR20")
    
    with open(f"i{iteration}.GTR20.iqtree") as iq:
        # Get BIC
        lines = iq.readlines()
        bic_1 = [ l.strip() for l in lines if "BIC" in l ][0]
        bic_1 = float(re.sub("Bayesian information criterion \(BIC\) score: ", "", bic_1))
        print(f"Iteration {iteration} BIC: {bic_1}")

        # Get Q-matrix and base frequencies
        grep_iqtree("can be used as input", f"Q.bac_locus_i{iteration}")
        # TODO: Add catch for 0 frequencies
        grep_iqtree("State frequencies: ", f"F.bac_locus_i{iteration}")
