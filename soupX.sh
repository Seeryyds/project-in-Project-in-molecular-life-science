#!/bin/bash 
#SBATCH -A naiss2024-22-757         # 项目编号
#SBATCH -p main                     # 分区名称
#SBATCH -t 0-12:00:00               # 设置运行的最大时间
#SBATCH -n 24                       # 使用的CPU核心数（根据需要调整）
#SBATCH -J soupx_process            # 作业名称
#SBATCH -e soupx_process.err        # 错误输出文件
#SBATCH -o soupx_process.out        # 标准输出文件
#SBATCH --mail-user=xuanyil@kth.se  # 邮箱地址
#SBATCH --mail-type=ALL             # 通知类型（开始、结束、失败等）

# 加载R模块，确保R环境已安装SoupX、Seurat等依赖包
module load R/4.3.2

# 运行R脚本
Rscript /cfs/klemming/projects/snic/rnaatlas/nobackup/private/xuanyi/Rscript/process_samples.R

