#!/usr/bin/bash

# parse .iqtree for tree length and +I/+G/+R parameters

grep -A 22 -P "Topology-unlinked partition model" $1 | sed '1,2d'
