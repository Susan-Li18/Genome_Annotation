#!/bin/bash
#SBATCH --job-name=run_seqkit
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=48G
#SBATCH --time=2:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-21
set -euo pipefail

COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR=/data/users/jli/genome_annotation_course/output/EDTA 
genome=assembly.fasta  # Replace with your assembly filename.

cd $WORKDIR
# Extract Copia sequences
apptainer exec -C --bind "$WORKDIR" "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" \
seqkit grep -r -p \
"Copia" $WORKDIR/$genome.mod.EDTA.TElib.fa > $WORKDIR/Copia_sequences.fa
# Extract Gypsy sequences
apptainer exec -C --bind "$WORKDIR" "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" \
seqkit grep -r -p \
"Gypsy" $WORKDIR/$genome.mod.EDTA.TElib.fa > $WORKDIR/Gypsy_sequences.fa
# run TEsorter
apptainer exec --bind $WORKDIR /data/courses/genome_annotation_resources/2026/containers/TEsorter_1.3.0.sif \
TEsorter $WORKDIR/Copia_sequences.fa -db rexdb-plant -p 4
apptainer exec --bind $WORKDIR /data/courses/genome_annotation_resources/2026/containers/TEsorter_1.3.0.sif \
TEsorter $WORKDIR/Gypsy_sequences.fa -db rexdb-plant -p 4
