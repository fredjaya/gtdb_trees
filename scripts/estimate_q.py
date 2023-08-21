#!/usr/bin/env python3  

import argparse
import subprocess
import os
import re
import sys 
import math 

def run_command(cmd):
    if args.verbose:
        print(cmd, "\n")
    process = subprocess.Popen(cmd, shell=True, text=True,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    exit_code = process.returncode
    if exit_code > 0:
        print(stderr)
        sys.exit()
    return stdout, stderr, exit_code

def grep_iqtree(string, filename):
    index = [ idx for idx, l in enumerate(lines) if string in l ][0]
    with open(filename, 'w') as f:
        # TODO: softcode for single concat tree
        f.writelines([ l.lstrip() for l in lines[index+2:index+22] ])

parser = argparse.ArgumentParser()
parser.add_argument('-s', '--loci', type=str, help='Path to concatenated loci', required=True)
#parser.add_argument('-p', '--partition', type=str, help='Path to partition file for concatenated loci', required=True)
parser.add_argument('--best_scheme', type=str, help='Path to .best_scheme file to select best starting models.', required=True)
parser.add_argument('-te', '--constrained', help='Estimate Q with a fixed topology.', required=False)
parser.add_argument('-T', '--threads', help='Threads to use (-T)', default=int(1), required=False)
parser.add_argument('-v', '--verbose', action='store_true', help='Print commands', required=False)

args = parser.parse_args()

all_schemes = {} 
model_counts = {}

with open(args.best_scheme, 'r') as scheme_file:
    schemes = []
    # Parse best_scheme file
    for line in scheme_file:
        line = line.strip()
        line = re.sub(" =", "", line)
        model,loc_name = line.split(', ')
        # Remove all appended "+F"
        model = re.sub("F$", "", model)
        schemes.append([line,loc_name])
        all_schemes["MF"] = schemes

        # Add frequency of models  
        model_counts[model] = model_counts.get(model, 0) +1

model_counts = sorted(model_counts.items(), key = lambda x: x[1], reverse=True)
print(model_counts)

"""
Identify the models that appear in the top X% of loci.
Default = 90%
"""
nloci = len(all_schemes["MF"])
cutoff=0.9
maxloci = math.ceil(nloci*cutoff)

print(f"Total loci: {nloci}\nCut-off: {cutoff}\nSelecting most frequent models\
 up to {maxloci} loci.")

cumulative_count = 0
starting_models = []

for i in model_counts:
    if cumulative_count <= maxloci:
        cumulative_count += i[1]
        starting_models.append(i[0])

print(f"Starting models: {starting_models}")

"""
Run constrained estimation 
"""
iqtree_binary = "~/Downloads/iqtree-2.2.2.7-Linux/bin/iqtree2"
seed = 1
if args.constrained:
    pearson = 0
    iteration=1
    #while pearson < 0.9: 
    """
    Run using the identified starting models 
    """
    run_command("mkdir -p 05_constrained")
    run_command(f"{iqtree_binary} --seed {seed} -T {args.threads} -p {args.loci} -m MFP -mset {','.join(starting_models)} -cmax 4 -te {args.constrained} -pre 05_constrained/i{iteration}")
    # TODO: Can add new models here, make above MF thing a function
    run_command("sed -i 's/, //' 05_constrained/i{iteration}.best_scheme.nex")
    run_command(f"{iqtree_binary} -seed {seed} -T {args.threads} -s {args.loci} -p 05_constrained/i{iteration}.best_scheme.nex -te {args.constrained} --model-joint GTR20+FO -pre 05_constrained/i{iteration}.GTR20")

    # TODO: Run sec
