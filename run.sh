#!/bin/bash

# Exit if any command fails
set -e

# SLURM Job Submission Directives
#SBATCH --job-name=AHDS          
#SBATCH --partition=teach_cpu            
#SBATCH --nodes=1                       
#SBATCH --ntasks=1                     
#SBATCH --cpus-per-task=1             
#SBATCH --mem=12G                      
#SBATCH --time=6:00:00                 
#SBATCH --output=AHDS_%j.log    
#SBATCH --account=kv24343

module load anaconda 
conda activate AHDS-env

snakemake all --cores 1
