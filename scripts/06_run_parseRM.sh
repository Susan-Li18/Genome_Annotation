#!/bin/bash
#SBATCH --job-name=run_parseRM
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=48G
#SBATCH --time=2:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -euo pipefail

COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR=/data/users/jli/genome_annotation_course/
genome=assembly.fasta

awk 'NR == 1 || $2 != 0' "$WORKDIR/output/EDTA/$genome.mod.EDTA.anno/$genome.mod.EDTA.RM.out" \
    > "$WORKDIR/output/EDTA/$genome.mod.EDTA.anno/$genome.mod.EDTA.RM.nonzero.out"

cd "$WORKDIR/output/EDTA/$genome.mod.EDTA.anno"

apptainer exec -C --bind "$WORKDIR" --bind "$COURSEDIR" --pwd $PWD \
    "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" \
    perl "$COURSEDIR/scripts/05-parseRM.pl" \
    -i "$genome.mod.EDTA.RM.nonzero.out" -l 50,1 -v