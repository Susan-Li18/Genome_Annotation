#!/bin/bash
#SBATCH --job-name=prepare_data
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem=8G
#SBATCH --time=03:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err


set -euo pipefail
WORKDIR=/data/users/jli/genome_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
Accession=Geg_14
FINALDIR="$WORKDIR/output/MAKER/final"
GENES="$FINALDIR/filtered.genes.renamed.gff3"
OUTDIR="$WORKDIR/output/comparisons"
GENESPACE_DIR="$OUTDIR/GENESPACE"
mkdir -p "$GENESPACE_DIR/bed" "$GENESPACE_DIR/peptide" "$GENESPACE_DIR/tmp"
# prepare my own accession to get BED file
grep -P "\tgene\t" "$GENES" > "$GENESPACE_DIR/temp_genes.gff3"
# Get the the first attribute in column 9 which is ID=gene_name.
awk 'BEGIN{OFS="\t"} {split($9,a,";"); split(a[1],b,"="); print $1, $4-1, $5, b[2]}' \
"$GENESPACE_DIR/temp_genes.gff3" > "$GENESPACE_DIR/bed/${Accession}.bed"
# match FASTA ID to BED gene ID
LONGEST_PROTEINS="$FINALDIR/assembly.all.maker.proteins.fasta.renamed.longest.fasta"
# Remove transcript suffixes and descriptions from FASTA headers.
sed '/^>/s/ .*//' "$LONGEST_PROTEINS" | sed '/^>/s/-R[A-Z]*$//' \
> "$GENESPACE_DIR/peptide/${Accession}.fa"

# add TAIR10
cp "$COURSEDIR/data/TAIR10.bed" "$GENESPACE_DIR/bed/TAIR10.bed"
cp "$COURSEDIR/data/TAIR10.fa" "$GENESPACE_DIR/peptide/TAIR10.fa"

for other in Etna_2 Altai_5 Are_6; do
cp "$COURSEDIR/data/Lian_et_al/GENESPACE/bed/${other}.bed" \
"$GENESPACE_DIR/bed/${other}.bed"
cp "$COURSEDIR/data/Lian_et_al/GENESPACE/peptide/${other}.fa" \
"$GENESPACE_DIR/peptide/${other}.fa"
done