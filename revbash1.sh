#!/bin/bash
#SBATCH -n 4
#SBATCH -t 5:00:00
#SBATCH --mem=16G

module load git
module load revbayes
rb GTR_Gamma.Rev
rb GTR_GammaEmpty.Rev

