
#!/bin/bash

# Exit if any command fails
set -e

# SLURM Job Submission Directives
# SLURM Job Submission Directives
#SBATCH --job-name=AHDS                  # Name of the job
#SBATCH --partition=teach_cpu            # Partition name
#SBATCH --nodes=1                        # Number of nodes
#SBATCH --ntasks=1                       # Number of tasks (typically the same as nodes for simple jobs)
#SBATCH --cpus-per-task=1                # Number of cores per task
#SBATCH --mem=16G                        # Memory per node
#SBATCH --time=12:00:00                  # Time limit hrs:min:sec
#SBATCH --output=AHDS_2553055_%j.log     # Standard output and error log
#SBATCH --account=kv24343

source /user/home/kv24343/miniconda3/etc/profile.d/conda.sh
conda activate AHDS-env

snakemake clean --cores 1
snakemake all --cores 1
