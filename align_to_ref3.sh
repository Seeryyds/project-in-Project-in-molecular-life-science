#!/bin/bash 
# naiss2024-22-757
#SBATCH -A naiss2024-22-757
#SBATCH -p main
#SBATCH -t 0-6:00:00
#SBATCH -n 2
#SBATCH -J align_to_ref3.sh
#SBATCH -e align_to_ref3.err
#SBATCH -o align_to_ref3.o
#SBATCH --mail-user=xuanyil@kth.se
#SBATCH --mail-type=ALL

module load bioinfo-tools
module load star/2.7.11a

# 设置工作目录和输出目录
base_dir="/cfs/klemming/projects/snic/rnaatlas/private/mouse/mouse_brain_sc/VISp/L8TX_210107_01_H08"
output_dir="/cfs/klemming/projects/supr/rnaatlas/nobackup/private/xuanyi/output3"
reference_directory="/cfs/klemming/projects/supr/rnaatlas/nobackup/private/xuanyi/ref/Mus_musculus.GRCm39.109.index"

# 白名单文件路径
whitelist_v2="/cfs/klemming/projects/supr/rnaatlas/nobackup/private/xuanyi/ref/737K-august-2016.txt"
whitelist_v3="/cfs/klemming/projects/supr/rnaatlas/nobackup/private/xuanyi/ref/3M-february-2018.txt"

# 样本列表：前6个是10Xv2，后4个是10Xv3
samples=("L8TX_171120_01_E07" "L8TX_171120_01_F07" "L8TX_180115_01_B08" "L8TX_180115_01_C08" "L8TX_180115_01_E08" "L8TX_180115_01_F08" \
         "L8TX_210107_01_C08" "L8TX_210107_01_F09" "L8TX_210107_01_G09" "L8TX_210107_01_H08")

# 遍历每个样本
for sample in "${samples[@]}"; do
  sample_dir="$base_dir/$sample"

  # 确认样本目录存在
  if [ ! -d "$sample_dir" ]; then
    echo "Warning: Sample directory $sample_dir does not exist. Skipping..."
    continue
  fi

  # 创建输出目录
  mkdir -p "$output_dir/$sample"

  # 自动识别read_2和read_3文件
  read_2=$(find "$sample_dir" -name "*_2.fastq.gz")
  read_3=$(find "$sample_dir" -name "*_3.fastq.gz")

  # 检查文件是否存在
  if [[ -z "$read_2" || -z "$read_3" ]]; then
    echo "Warning: Missing required files for $sample. Skipping..."
    continue
  fi

  # 根据样本名称选择10X版本
  if [[ " ${samples[@]:0:6} " =~ " $sample " ]]; then
    # 10X v2 设置
    whitelist="$whitelist_v2"
    cb_len=16
    umi_len=10
  else
    # 10X v3 设置
    whitelist="$whitelist_v3"
    cb_len=16
    umi_len=12
  fi

  echo "Processing sample: $sample"
  echo "Read 2 file: $read_2"
  echo "Read 3 file: $read_3"
  echo "Using whitelist: $whitelist, CB length: $cb_len, UMI length: $umi_len"


    # 执行 STAR
STAR --genomeDir "$reference_directory" \
       --soloType CB_UMI_Simple \
       --readFilesCommand zcat \
       --readFilesIn "$read_3" "$read_2" \
       --runDirPerm All_RWX \
       --soloCBwhitelist "$whitelist" \
       --soloCBstart 1 \
       --soloCBlen $cb_len \
       --soloUMIstart 17 \
       --soloUMIlen $umi_len \
       --soloBarcodeReadLength 0 \
       --outFileNamePrefix "$output_dir/$sample/" \
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
