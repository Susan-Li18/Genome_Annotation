#!/bin/bash
#SBATCH --job-name=circlize_visulization
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=48G
#SBATCH --time=20:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err


COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR=/data/users/jli/genome_annotation_course 
GENOME="$WORKDIR/data/assemblies/assembly.fasta"  # Edit for your assembly.
GENOME="$(readlink -f "$GENOME")" 
#step 1: generate fasta index
apptainer exec -C --bind "$WORKDIR" --bind "$(dirname "$GENOME")" "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" \
samtools faidx $GENOME

# Place the index where the R script expects it
cp "${GENOME}.fai" "$WORKDIR/data/assemblies/assembly.fasta.fai"
# step 2: generate circos visualization
apptainer exec -C --bind "$WORKDIR" "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" \
Rscript "$WORKDIR/scripts/04-annotation_circlize.R"