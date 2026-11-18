# Load the circlize package
library(circlize)
library(tidyverse)
library(ComplexHeatmap)


# Load the TE annotation GFF3 file
gff_file <- "/data/users/jli/genome_annotation_course/output/EDTA/assembly.fasta.mod.EDTA.anno/assembly.fasta.mod.EDTA.TEanno.gff3"
gff_data <- read.table(gff_file, header = FALSE, sep = "\t", stringsAsFactors = FALSE)

# Check the superfamilies present in the GFF3 file, and their counts
gff_data$V3 %>% table()


# custom ideogram data
## To make the ideogram data, you need to know the lengths of the scaffolds.
## There is an index file that has the lengths of the scaffolds, the `.fai` file.
## To generate this file you need to run the following command in bash:
## samtools faidx assembly.fasta
## This will generate a file named assembly.fasta.fai
## You can then read this file in R and prepare the custom ideogram data

custom_ideogram <- read.table("/data/users/jli/genome_annotation_course/data/assemblies/assembly.fasta.fai", header = FALSE, stringsAsFactors = FALSE)
custom_ideogram$chr <- custom_ideogram$V1
custom_ideogram$start <- 1
custom_ideogram$end <- custom_ideogram$V2
custom_ideogram <- custom_ideogram[, c("chr", "start", "end")]
custom_ideogram <- custom_ideogram[order(custom_ideogram$end, decreasing = T), ]
sum(custom_ideogram$end[1:20])

# Select only the first 20 longest scaffolds, You can reduce this number if you have longer chromosome scale scaffolds
custom_ideogram <- custom_ideogram[1:20, ]

# Function to filter GFF3 data based on Superfamily (You need one track per Superfamily)
filter_superfamily <- function(gff_data, superfamily, custom_ideogram) {
    filtered_data <- gff_data[gff_data$V3 == superfamily, ] %>%
        as.data.frame() %>%
        mutate(chrom = V1, start = V4, end = V5, strand = V6) %>%
        select(chrom, start, end, strand) %>%
        filter(chrom %in% custom_ideogram$chr)
    return(filtered_data)
}

plot_dir <- "/data/users/jli/genome_annotation_course/plots"
dir.create(plot_dir, showWarnings = FALSE, recursive = TRUE)
pdf(file.path(plot_dir, "02-TE_density.pdf"), width = 10, height = 10)
gaps <- c(rep(1, length(custom_ideogram$chr) - 1), 5) # Add a gap between scaffolds, more gap for the last scaffold
circos.par(start.degree = 90, gap.after = 1, track.margin = c(0, 0), gap.degree = gaps)
# Initialize the circos plot with the custom ideogram
circos.genomicInitialize(custom_ideogram)

# Plot te density
circos.genomicDensity(filter_superfamily(gff_data, "Gypsy_LTR_retrotransposon", custom_ideogram), count_by = "number", col = "darkgreen", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_superfamily(gff_data, "Copia_LTR_retrotransposon", custom_ideogram), count_by = "number", col = "darkred", track.height = 0.07, window.size = 1e5)
circos.clear()

lgd <- Legend(
    title = "Superfamily", at = c("Gypsy_LTR_retrotransposon", "Copia_LTR_retrotransposon"),
    legend_gp = gpar(fill = c("darkgreen", "darkred"))
)
draw(lgd, x = unit(8, "cm"), y = unit(10, "cm"), just = c("center"))

dev.off()


# Now plot all your most abundant TE superfamilies in one plot

# Keep top-level TE features only (drop LTR/TSD subfeatures, parent regions and unclassified fragments)
exclude_feats <- c("long_terminal_repeat", "target_site_duplication", "repeat_region", "repeat_fragment")
te_features <- gff_data[!gff_data$V3 %in% exclude_feats, ]
# TE_00000198 is a CEN180-like centromeric satellite misclassified by EDTA as MITE/DTM; exclude it
te_features <- te_features[!grepl("Name=TE_00000198;", te_features$V9, fixed = TRUE), ]

# Rank superfamilies by number of annotated copies on the plotted scaffolds
sf_counts <- te_features %>%
    filter(V1 %in% custom_ideogram$chr) %>%
    count(V3, sort = TRUE)
message("TE copies per superfamily on the plotted scaffolds:")
print(sf_counts)

top_sf <- head(sf_counts$V3, 5)
top_cols <- c("#1b9e77", "#d95f02", "#7570b3", "#e7298a", "#66a61e")[seq_along(top_sf)]

pdf(file.path(plot_dir, "02-TE_density_top_superfamilies.pdf"), width = 10, height = 10)
circos.par(start.degree = 90, gap.after = 1, track.margin = c(0, 0), gap.degree = gaps)
circos.genomicInitialize(custom_ideogram)
for (i in seq_along(top_sf)) {
    circos.genomicDensity(filter_superfamily(te_features, top_sf[i], custom_ideogram),
        count_by = "number", col = top_cols[i], track.height = 0.07, window.size = 1e5
    )
}
circos.clear()
lgd <- Legend(title = "Superfamily", at = top_sf, legend_gp = gpar(fill = top_cols))
draw(lgd, x = unit(8, "cm"), y = unit(10, "cm"), just = c("center"))
dev.off()

# Plot the distribution of Athila and CRM clades (known centromeric TEs in Brassicaceae).
# You need to run the TEsorter on TElib to get the clades classification from the TE library

# --- Clade abundance: link TEsorter clades (TE library) to genomic copies (TEanno.gff3) ---
# TEsorter IDs look like "TE_00000005#LTR/Gypsy"; the GFF links each copy to its family via Name=TE_00000005.
edta_dir <- "/data/users/jli/genome_annotation_course/output/EDTA"
read_cls <- function(f) {
    # comment.char = "" because the TE IDs themselves contain "#"
    x <- read.table(f, sep = "\t", header = FALSE, skip = 1, comment.char = "", quote = "", stringsAsFactors = FALSE)
    data.frame(Name = sub("#.*$", "", x$V1), Superfamily = x$V3, Clade = x$V4)
}
clade_cls <- bind_rows(
    read_cls(file.path(edta_dir, "Copia_sequences.fa.rexdb-plant.cls.tsv")),
    read_cls(file.path(edta_dir, "Gypsy_sequences.fa.rexdb-plant.cls.tsv"))
) %>% distinct(Name, .keep_all = TRUE)

te_clades <- te_features %>%
    mutate(Name = str_match(V9, "Name=([^;]+)")[, 2], bp = V5 - V4 + 1) %>%
    inner_join(clade_cls, by = "Name")

# Genome-wide abundance of each clade (all scaffolds; intact + fragmented copies)
clade_abundance <- te_clades %>%
    group_by(Superfamily, Clade) %>%
    summarise(families = n_distinct(Name), copies = n(), Mb = round(sum(bp) / 1e6, 3), .groups = "drop") %>%
    arrange(Superfamily, desc(copies))
message("Genome-wide abundance of Copia and Gypsy clades:")
print(clade_abundance, n = Inf)
write.table(clade_abundance, file.path(edta_dir, "TE_clade_abundance.tsv"),
    sep = "\t", quote = FALSE, row.names = FALSE
)

# --- Circos plot of Athila and CRM clades ---
filter_clade <- function(df, clade, custom_ideogram) {
    df %>%
        filter(Clade == clade, V1 %in% custom_ideogram$chr) %>%
        transmute(chrom = V1, start = V4, end = V5, strand = V6)
}
clade_cols <- c(Athila = "#d95f02", CRM = "#7570b3")

pdf(file.path(plot_dir, "02-TE_density_Athila_CRM.pdf"), width = 10, height = 10)
circos.par(start.degree = 90, gap.after = 1, track.margin = c(0, 0), gap.degree = gaps)
circos.genomicInitialize(custom_ideogram)
for (cl in names(clade_cols)) {
    circos.genomicDensity(filter_clade(te_clades, cl, custom_ideogram),
        count_by = "number", col = clade_cols[[cl]], track.height = 0.07, window.size = 1e5
    )
}
circos.clear()
lgd <- Legend(title = "Gypsy clade", at = names(clade_cols), legend_gp = gpar(fill = clade_cols))
draw(lgd, x = unit(8, "cm"), y = unit(10, "cm"), just = c("center"))
dev.off()
