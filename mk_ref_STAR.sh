#!/bin/bash
# naiss2024-22-757 
#SBATCH -A naiss2024-22-757 
#SBATCH -p main
#SBATCH -t 0-1:00:00
#SBATCH -n 1
#SBATCH -J mk_ref_STAR.sh
#SBATCH -e mk_ref_STAR.err
#SBATCH -o mk_ref_STAR.o
#SBATCH --mail-user xuanyil@kth.se
#SBATCH --mail-type=ALL

## Script to setup the reference to be used with STARsolo

module load bioinfo-tools
module load star/2.7.11a

# 
VERSION=109
ref_name=Mus_musculus_GRCm39_"$VERSION".index
gtf_file=Mus_musculus.GRCm39."$VERSION".gtf
fasta_file=Mus_musculus.GRCm39.dna.toplevel.fa

# swtich dictionary
cd /cfs/klemming/projects/supr/rnaatlas/nobackup/private/xuanyi

# STAR to produce index
STAR --runMode genomeGenerate \
 --runThreadN 18 \
 --genomeDir $ref_name \
 --genomeFastaFiles $fasta_file \
 --sjdbGTFfile $gtf_file \
 --sjdbOverhang 99
