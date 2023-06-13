#!/usr/bin/env python3 
"""
Returns a fasta file with no empty sequences.  

For constrained locus tree analyses as IQ-TREE drops empty sequences, the taxa
in the input sequence and constrained tree need to match.  

Input:
    fasta
"""

from Bio import SeqIO
import sys
import re

def remove_empty_sequences(input_file, output_file):
    with open(input_file, "r") as f:
        sequences = list(SeqIO.parse(f, "fasta"))
   
    # Omit sequence if it consists entirely of gaps
    non_empty_sequences = [seq for seq in sequences if seq.seq.count('-') != len(seq)]

    # Write new fasta with non-empties
    with open(output_file, "w") as f:
        SeqIO.write(non_empty_sequences, f, "fasta")
    print("Empty sequences removed and saved to", output_file)

input_file = sys.argv[1]
output_file = re.sub(".*\/", "", input_file)
output_file += "_noEmptyTaxa"

remove_empty_sequences(input_file, output_file)
