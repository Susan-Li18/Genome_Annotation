#!/bin/bash
#SBATCH --job-name=run_div
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

apptainer exec -C --bind "$WORKDIR" --bind "$COURSEDIR" --pwd $WORKDIR $COURSEDIR/containers/Annotation_analysis_R4.4.sif \
Rscript --vanilla $WORKDIR/scripts/06-plot_div.R