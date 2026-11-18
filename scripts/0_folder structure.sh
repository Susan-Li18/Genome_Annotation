WORKDIR="/data/users/$USER/genome_annotation_course"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
mkdir -p data/{assemblies,transcripts,proteins} scripts logs \
results/{TE_annotation,gene_annotation,comparisons} plots