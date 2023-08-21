#!/usr/bin/env python3  

import argparse
import subprocess
import os
import re
import math 

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
parser.add_argument('--best_scheme', type=str, help='Path to .best_scheme file to select best starting models.', required=True)
#parser.add_argument('-te', '--constrained', help='Estimate Q with a fixed topology.', required=False)
parser.add_argument('-T', '--threads', help='Threads to use (-T)', required=True)
parser.add_argument('-v', '--verbose', action='store_true', help='Print commands', required=False)

args = parser.parse_args()

locus_schemes = []
model_counts = {}

with open(args.best_scheme, 'r') as scheme_file:
    # Parse best_scheme file
    for line in scheme_file:
        line = line.strip()
        line = re.sub(" =", "", line)
        model,loc_name = line.split(', ')
        # Remove all appended "+F"
        model = re.sub("F$", "", model)
        locus_schemes.append([line,loc_name])

        # Add frequency of models  
        model_counts[model] = model_counts.get(model, 0) +1


model_counts = sorted(model_counts.items(), key = lambda x: x[1], reverse=True)
print(model_counts)

"""
Identify the models that appear in the top X% of loci.
Default = 90%
"""
nloci = len(locus_schemes)
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
