#!/bin/bash
set -euo pipefail
protein="assembly.all.maker.proteins.fasta"
transcript="assembly.all.maker.transcripts.fasta"
WORKDIR="/data/users/jli/genome_annotation_course"
FINALDIR="$WORKDIR/output/MAKER/final"
cd "$FINALDIR"

# get the longest protein 
awk '
/^>/ {
    if (seq != "") print id, seq, length(seq)
    id = substr($1, 2)
    seq = ""
    next
}
{seq = seq $0}
END {
    if (seq != "") print id, seq, length(seq)
}' OFS='\t' "./${protein}.renamed.filtered.fasta" > ./protein_lengths.tsv

awk -F '\t' '
{
    gene = $1
    sub(/-R.*$/, "", gene)

    if (!(gene in max) || $3 > max[gene]) {
        max[gene] = $3
        id[gene] = $1
        seq[gene] = $2
    }
}
END {
    for (gene in id)
        print ">" id[gene] "\n" seq[gene]
}' ./protein_lengths.tsv > "./${protein}.renamed.longest.fasta"

# get the longest transcripts
awk '
/^>/ {
    if (seq != "") print id, seq, length(seq)
    id = substr($1, 2)
    seq = ""
    next
}
{seq = seq $0}
END {
    if (seq != "") print id, seq, length(seq)
}' OFS='\t' "./${transcript}.renamed.filtered.fasta" > ./transcript_lengths.tsv

awk -F '\t' '
{
    gene = $1
    sub(/-R.*$/, "", gene)

    if (!(gene in max) || $3 > max[gene]) {
        max[gene] = $3
        id[gene] = $1
        seq[gene] = $2
    }
}
END {
    for (gene in id)
        print ">" id[gene] "\n" seq[gene]
}' ./transcript_lengths.tsv > "./${transcript}.renamed.longest.fasta"