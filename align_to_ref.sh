#!/bin/bash
# naiss2024-22-757
#SBATCH -A naiss2024-22-757
#SBATCH -p main
#SBATCH -t 0-6:00:00
#SBATCH -n 1
#SBATCH -J align_to_ref.sh
#SBATCH -e align_to_ref.err
#SBATCH -o align_to_ref.o
#SBATCH --mail-user=xuanyil@kth.se
#SBATCH --mail-type=ALL

module load bioinfo-tools
module load star/2.7.11a

# Set working directory and reference genome path
cd /cfs/klemming/projects/snic/rnaatlas/private/mouse/mouse_brain_sc/VISp

# Define output directory and reference index path
output_dir=/cfs/klemming/projects/snic/rnaatlas/nobackup/private/xuanyi/output
reference_directory=/cfs/klemming/projects/snic/rnaatlas/nobackup/private/xuanyi/ref/Mus_musculus.GRCm39.109.index

# Loop through each organ and sample
for organ in *; do
  # Create output directory for each organ if it doesn't exist
  if [ ! -d "$output_dir/$organ" ]; then
    echo "Creating directory: $output_dir/$organ"
    mkdir -p "$output_dir/$organ"
  fi
  
  for sample in "$organ"/*; do
    # Skip samples with '_Oligo' in the name
    if [[ "$sample" == *_Oligo ]]; then
      continue
    fi
    
    # Create output directory for each sample if it doesn't exist
    if [ ! -d "$output_dir/$sample" ]; then
      echo "Creating directory: $output_dir/$sample"
      mkdir -p "$output_dir/$sample"
      
      # Identify read_1 and read_2 files
      for read in "$sample"/*.fq.gz; do
        if [[ "$read" == *1.fq.gz ]]; then
          read_1=$read
        elif [[ "$read" == *2.fq.gz ]]; then
          read_2=$read
        fi
      done
      
      # Run STAR alignment for each sample
      STAR --genomeDir "$reference_directory" \
           --soloType CB_UMI_Simple \
           --readFilesCommand zcat \
           --readFilesIn "$read_2" "$read_1" \
           --soloCBwhitelist ref/3M-february-2018.txt \
           --soloCBstart 1 \
           --soloCBlen 20 \
           --soloUMIstart 21 \
           --soloUMIlen 10 \
           --outFileNamePrefix "$output_dir/$sample/" \
           --limitOutSJcollapsed 2000000 \
           --runThreadN 18 \
           --soloCBmatchWLtype 1MM_multi_Nbase_pseudocounts \
           --soloCellFilter EmptyDrops_CR \
           --soloUMIfiltering MultiGeneUMI_CR \
           --soloUMIdedup 1MM_CR \
           --soloFeatures Gene Velocyto \
           --soloMultiMappers EM \
           --outSAMtype None
    fi
  done
done
