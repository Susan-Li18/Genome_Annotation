#!/bin/bash
#SBATCH --job-name=run_map
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem=10G
#SBATCH --time=02:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -euo pipefail
WORKDIR=/data/users/jli/genome_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
ANALYSIS_SIF="$COURSEDIR/containers/genespace_latest.sif"
TMPDIR="$WORKDIR/output/comparisons/map_R_tmp"
mkdir -p "$TMPDIR"
apptainer exec --cleanenv \
--bind /data --bind "$WORKDIR" \
--bind "$TMPDIR":/temp --env TMPDIR=/temp --pwd "$WORKDIR" \
"$ANALYSIS_SIF" Rscript "$WORKDIR/scripts/26_syntenymap.R"