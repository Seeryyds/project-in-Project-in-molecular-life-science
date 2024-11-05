#!/bin/bash 
#SBATCH -A naiss2024-22-757
#SBATCH -p main
#SBATCH -t 0-6:00:00
#SBATCH -n 1
#SBATCH -J align_to_ref2
#SBATCH -e align_to_ref2.err
#SBATCH -o align_to_ref2.o
#SBATCH --mail-user=xuanyil@kth.se
#SBATCH --mail-type=ALL

module load bioinfo-tools
module load star/2.7.11a

# 设置参考目录、输出目录和白名单路径
reference_directory="/cfs/klemming/projects/snic/rnaatlas/nobackup/private/xuanyi/ref/Mus_musculus.GRCm39.109.index"
output_dir="/cfs/klemming/projects/supr/rnaatlas/nobackup/private/xuanyi/output2"
whitelist_v2="/cfs/klemming/projects/supr/rnaatlas/nobackup/private/xuanyi/ref/737K-august-2016.txt"
whitelist_v3="/cfs/klemming/projects/supr/rnaatlas/nobackup/private/xuanyi/ref/3M-february-2018.txt"

# 定义 v2 和 v3 样本列表
v2_samples=("L8TX_171120_01_E07" "L8TX_171120_01_F07" "L8TX_180115_01_B08" "L8TX_180115_01_C08" "L8TX_180115_01_E08" "L8TX_180115_01_F08")
v3_samples=("L8TX_210107_01_C08" "L8TX_210107_01_F09" "L8TX_210107_01_G09" "L8TX_210107_01_H08")

# 循环遍历每个样本
for sample in "${v2_samples[@]}" "${v3_samples[@]}"; do
    # 检查样本文件夹是否存在
    sample_dir="/cfs/klemming/projects/snic/rnaatlas/private/mouse/mouse_brain_sc/VISp/$sample"
    if [ ! -d "$sample_dir" ]; then
        echo "Warning: Sample directory $sample_dir does not exist. Skipping..."
        continue
    fi

    # 设置文件路径
    read_1="$sample_dir/${sample}_1.fastq.gz"
    read_2="$sample_dir/${sample}_2.fastq.gz"
    read_3="$sample_dir/${sample}_3.fastq.gz"

    # 检查文件是否存在
    if [ ! -f "$read_1" ] || [ ! -f "$read_2" ] || [ ! -f "$read_3" ]; then
        echo "Warning: Missing required files for $sample. Skipping..."
        continue
    fi

    # 创建输出目录
    sample_output_dir="$output_dir/$sample"
    mkdir -p "$sample_output_dir"

    # 判断样本类型（v2 或 v3），并设置相应参数
    if [[ " ${v2_samples[@]} " =~ " ${sample} " ]]; then
        whitelist="$whitelist_v2"
        CB_len=16
        UMI_len=10
        echo "Processing v2 sample: $sample"
    elif [[ " ${v3_samples[@]} " =~ " ${sample} " ]]; then
        whitelist="$whitelist_v3"
        CB_len=16
        UMI_len=12
        echo "Processing v3 sample: $sample"
    else
        echo "Warning: Sample $sample not found in v2 or v3 lists. Skipping..."
        continue
    fi

    # 执行 STAR
    STAR --genomeDir "$reference_directory" \
         --soloType CB_UMI_Simple \
         --readFilesCommand zcat \
         --readFilesIn "$read_2" "$read_3" \
         --soloCBwhitelist "$whitelist" \
         --soloCBstart 1 \
         --soloCBlen "$CB_len" \
         --soloUMIstart 17 \
         --soloUMIlen "$UMI_len" \
         --soloBarcodeReadLength 0 \
         --limitOutSJcollapsed 2000000 \
         --runThreadN 24 \
         --outFilterMismatchNoverLmax 0.05 \
         --outFilterMatchNmin 15 \
         --soloCBmatchWLtype 1MM_multi_Nbase_pseudocounts \
         --soloCellFilter EmptyDrops_CR \
         --soloUMIfiltering MultiGeneUMI_CR \
         --soloUMIdedup 1MM_CR \
         --soloFeatures Gene Velocyto \
         --soloMultiMappers EM \
         --outSAMtype None
done
