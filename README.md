# Health Data Science Mini Project

## Overview

This project automates the process of fetching, cleaning, and analyzing research articles from PubMed based on specific keywords. The pipeline includes scripts for data fetching, cleaning article titles, analyzing word frequency, and performing Latent Dirichlet Allocation (LDA) for topic modeling.

## Prerequisites

- Unix-based operating system (Linux)
- Python 3.8+
- R programming environment

## Environment Setup

1. Clone the repository:
   ```
   git clone https://github.com/chuhanzhou02/AHDS_RE.git
   ```

2. Install required Python and R packages:
   ```
   conda config --set channel_priority flexible
   conda env create -f environment.yaml
   conda activate AHDS-env
   ```

## Running the Pipelinea
To run the entire pipeline, use the provided `Snakefile` which orchestrates the execution of scripts in the correct order:

```
snakemake
```

on BlueCrystal:

```
sbatch run.sh
```

## Alternatively, individual components can be run as follows:

1. **download PubMed data:**
   ```
   snakemake download_data
   ```
  
2. **Processing Articles:**
   - To clean the data and remove unnecessary tags, run the following command:
     ```
     snakemake clean_data
     ```
   - Clean Titles:
     ```
     snakemake clean_title
     ```

3. **Data Visualisation:**
   - Word Frequency Analysis:
     ```
     snakemake plot
     ```
  
4. **Clean Data**
   - Remove data and plots directories:
     ```
     snakemake clean
     ```

# data: Holds project data.
   - raw: Stores raw data fetched from PubMed.
   - clean: Contains processed and cleaned data.
   - plots: Stores the results of data visualizations, such as word frequency graphs or LDA topic models.
   

