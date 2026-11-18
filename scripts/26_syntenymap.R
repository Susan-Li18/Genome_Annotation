library(GENESPACE)
wd <- "/data/users/jli/genome_annotation_course/output/comparisons/GENESPACE"
focal_genome <- "Geg_14"
load(file.path(wd, "results", "gsParams.rda")) # Loads gsParam.
dir.create(file.path(wd, "processed_riparian"), showWarnings = FALSE)

#Compare your accession with TAIR10, ordering scaffolds by synteny
plot_riparian(
gsParam,
genomeIDs = c("TAIR10", focal_genome),
refGenome = "TAIR10",
reorderBySynteny = TRUE,
pdfFile = file.path(wd, "processed_riparian", "my_accession_vs_TAIR10.pdf")
)

#Improve scaffold order and display orientation.
# Flip scaffolds whose main syntenic connection to TAIR10 is reversed.
flips <- data.frame(
  genome = focal_genome,
  chr = c(
    "contig_14", "contig_15", "contig_22",
    "contig_23", "contig_24", "contig_26",
    "contig_28", "contig_30", "contig_34",
    "contig_36", "contig_37", "contig_46",
    "contig_47", "contig_56", "contig_60"
  )
)
plot_riparian(
gsParam,
genomeIDs = c("TAIR10", focal_genome),
refGenome = "TAIR10",
reorderBySynteny = TRUE,
syntenyWeight = 1,
invertTheseChrs = flips,
pdfFile = file.path(wd, "processed_riparian", "my_accession_vs_TAIR10_oriented.pdf")
)

# Show all five genomes
plot_riparian(
gsParam,
refGenome = "TAIR10",
reorderBySynteny = TRUE,
syntenyWeight = 1,
invertTheseChrs = flips,
scalePlotWidth = 1.5,
pdfFile = file.path(wd, "processed_riparian", "all_genomes_TAIR10.pdf")
)