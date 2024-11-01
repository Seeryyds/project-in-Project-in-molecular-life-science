#!/bin/bash
#SBATCH -A naiss2024-22-757
#SBATCH -p main
#SBATCH -t 0-6:00:00
#SBATCH -n 4
#SBATCH -J align_to_ref.sh
#SBATCH -e align_to_ref.err
#SBATCH -o align_to_ref.o
#SBATCH --mail-user=xuanyil@kth.se
#SBATCH --mail-type=ALL

module load bioinfo-tools
module load star/2.7.11a

# Set working directory to the data folder
cd /cfs/klemming/projects/snic/rnaatlas/private/mouse/mouse_brain_sc/VISp

# Define output directory and reference index path
output_dir=/cfs/klemming/projects/supr/rnaatlas/nobackup/private/xuanyi/output
reference_directory=/cfs/klemming/projects/supr/rnaatlas/nobackup/private/xuanyi/ref/Mus_musculus.GRCm39.109.index

# Define the whitelist paths
whitelist_v2="/cfs/klemming/projects/supr/rnaatlas/nobackup/private/xuanyi/ref/737K-august-2016.txt"
whitelist_v3="/cfs/klemming/projects/supr/rnaatlas/nobackup/private/xuanyi/ref/3M-february-2018.txt"

# Define arrays for v2 and v3 samples
samples_v2=("L8TX_171120_01_E07" "L8TX_171120_01_F07" "L8TX_180115_01_B08" "L8TX_180115_01_C08" "L8TX_180115_01_E08" "L8TX_180115_01_F08")
samples_v3=("L8TX_210107_01_C08" "L8TX_210107_01_F09" "L8TX_210107_01_G09" "L8TX_210107_01_H08")

# Loop through each sample directory
for sample in *; do
  # Skip if not a valid sample
  if [[ ! -d "$sample" ]]; then
    continue
  fi
  
  # Check if the sample is v2 or v3 and set parameters accordingly
  if [[ " ${samples_v2[@]} " =~ " $sample " ]]; then
    whitelist="$whitelist_v2"
    cb_len=16
    umi_len=10
  elif [[ " ${samples_v3[@]} " =~ " $sample " ]]; then
    whitelist="$whitelist_v3"
    cb_len=16
    umi_len=12
  else
    echo "Warning: Sample $sample not found in v2 or v3 lists. Skipping..."
    continue
  fi
  
  # Define paths for read files
  read_2="$sample/${sample}_2.fastq.gz"  # Technical read with UMI and barcode
  read_3="$sample/${sample}_3.fastq.gz"  # Biological read
  
  # Create output directory for the sample if it doesn't exist
  if [ ! -d "$output_dir/$sample" ]; then
    echo "Creating directory: $output_dir/$sample"
    mkdir -p "$output_dir/$sample"
  fi
  
  # Ensure read files are available
  if [[ ! -f "$read_2" || ! -f "$read_3" ]]; then
    echo "Warning: Missing required files for $sample. Skipping..."
    continue
  fi

  # Run STAR alignment
  STAR --genomeDir "$reference_directory" \
       --soloType CB_UMI_Simple \
       --readFilesCommand zcat \
       --readFilesIn "$read_2" "$read_3" \
       --soloCBwhitelist "$whitelist" \
       --soloCBstart 1 \
       --soloCBlen "$cb_len" \
       --soloUMIstart 17 \
       --soloUMIlen "$umi_len" \
       --soloBarcodeReadLength 0 \
       --outFileNamePrefix "$output_dir/$sample/" \
       --limitOutSJcollapsed 2000000 \
       --runThreadN 4 \
       --soloCellFilter EmptyDrops_CR \
       --soloUMIfiltering MultiGeneUMI_CR \
       --soloUMIdedup 1MM_CR \
       --soloFeatures Gene Velocyto \
       --soloMultiMappers EM \
       --outSAMtype None
done


