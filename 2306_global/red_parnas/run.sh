#!/bin/bash
#SBATCH --job-name=parnas
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=320G
#SBATCH --time=3:00:00
#SBATCH --output=/mnt/data/dayhoff/home/u1070770/gtdb/02_working/2307_parnas/s/red_075.out
#SBATCH --error=/mnt/data/dayhoff/home/u1070770/gtdb/02_working/2307_parnas/s/red_075.err

cd /mnt/data/dayhoff/home/u1070770/gtdb/02_working/2307_parnas
parnas -t gtdb_r207_bac120_unscaled.decorated.scaled.tree --cover --radius 0.75 --subtree red_r075.tre
