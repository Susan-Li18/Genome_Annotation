#!/bin/bash
#SBATCH --job-name=run_genespace
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=64G
#SBATCH --time=02:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err


set -euo pipefail
WORKDIR=/data/users/jli/genome_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
GENESPACE_DIR="$WORKDIR/output/comparisons/GENESPACE"
GENESPACE_SIF="$COURSEDIR/containers/genespace_latest.sif"
# Use host-backed temporary storage for R's parallel workers.
TMPDIR="$WORKDIR/output/comparisons/GENESPACE_R_tmp"
mkdir -p "$TMPDIR"
cd "$WORKDIR"
apptainer exec --cleanenv \
--bind /data --bind "$WORKDIR" \
--bind "$TMPDIR":/temp --env TMPDIR=/temp --pwd "$WORKDIR" \
"$GENESPACE_SIF" Rscript "$WORKDIR/scripts/22_genespace.R" "$GENESPACE_DIR"