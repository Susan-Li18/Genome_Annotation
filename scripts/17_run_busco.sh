#!/bin/bash
#SBATCH --job-name=run_busco
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
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



module load BUSCO/5.4.2-foss-2021a
export PYTHONNOUSERSITE=1
# Run BUSCO on the LONGEST protein and transcript sequences
busco -i "$FINALDIR/${protein}.renamed.longest.fasta" -l brassicales_odb10 -o busco_proteins -m proteins -c 4
busco -i "$FINALDIR/${transcript}.renamed.longest.fasta" -l brassicales_odb10 -o busco_transcripts -m transcriptome -c 4