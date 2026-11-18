#!/bin/bash
#SBATCH --job-name=run_AGAT
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-28
WORKDIR="/data/users/jli/genome_annotation_course"
COURSEDIR=/data/courses/genome_annotation_resources/2026
OUTDIR="$WORKDIR/output/MAKER"
FINALDIR="$OUTDIR/final"
protein="assembly.all.maker.proteins.fasta"
transcript="assembly.all.maker.transcripts.fasta"
gff="assembly.all.maker.noseq.gff"
cd "$FINALDIR"

AGAT_SIF="$COURSEDIR/containers/AGAT_v1.4.1.sif"
apptainer exec --cleanenv --bind "$COURSEDIR" --bind "$WORKDIR" --pwd "$FINALDIR" "$AGAT_SIF" \
agat_sp_statistics.pl --gff filtered.genes.renamed.gff3 --output annotation.stat 