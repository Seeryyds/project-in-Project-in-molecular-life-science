#!/bin/bash 
#SBATCH -A naiss2024-22-757
#SBATCH -p main
#SBATCH -t 0-12:00:00
#SBATCH -n 2
#SBATCH -J soupx_process
#SBATCH -e soupx_process.err
#SBATCH -o soupx_process.out
#SBATCH --mail-user=xuanyil@kth.se
#SBATCH --mail-type=ALL

# 加载 Conda
source ~/miniconda3/etc/profile.d/conda.sh

# 激活 Conda 环境
conda activate r_env

# 运行 R 脚本
Rscript /cfs/klemming/projects/supr/rnaatlas/nobackup/private/xuanyi/Rscript/process_samples.R

# 结束后停用 Conda 环境
conda deactivate
