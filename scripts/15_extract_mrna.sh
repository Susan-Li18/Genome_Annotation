#!/bin/bash
#SBATCH --job-name=extract_mRNA
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
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"
protein="assembly.all.maker.proteins.fasta"
transcript="assembly.all.maker.transcripts.fasta"
gff="assembly.all.maker.noseq.gff"
cd "$FINALDIR"

grep -P "\tmRNA\t" filtered.genes.renamed.gff3 | awk '{print $9}' | cut -d ';' -f1 | sed 's/ID=//g' > list.txt
ANALYSIS_SIF="$COURSEDIR/containers/Annotation_analysis_R4.4.sif"
apptainer exec --cleanenv --bind "$COURSEDIR" --bind "$WORKDIR" --pwd "$FINALDIR" "$ANALYSIS_SIF" seqkit grep \
-f list.txt ${transcript}.renamed.fasta -o ${transcript}.renamed.filtered.fasta
apptainer exec --cleanenv --bind "$COURSEDIR" --bind "$WORKDIR" --pwd "$FINALDIR" "$ANALYSIS_SIF" seqkit grep \
-f list.txt ${protein}.renamed.fasta -o ${protein}.renamed.filtered.fasta