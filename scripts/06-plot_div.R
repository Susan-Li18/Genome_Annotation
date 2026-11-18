library(reshape2)
# library(hrbrthemes)
library(tidyverse)
library(data.table)


# get data from parameter

data <- "/data/users/jli/genome_annotation_course/output/EDTA/assembly.fasta.mod.EDTA.anno/assembly.fasta.mod.EDTA.RM.nonzero.out.landscape.Div.Rname.tab"

rep_table <- fread(data, header = FALSE, sep = "\t")
rep_table %>% head()
# How does the data look like?

colnames(rep_table) <- c("Rname", "Rclass", "Rfam", 1:50)
rep_table <- rep_table %>% filter(Rfam != "unknown")  %>% filter(Rname != "TE_00000198") # CEN180-like centromeric satellite, misclassified as MITE/DTM by EDTA

rep_table$fam <- paste(rep_table$Rclass, rep_table$Rfam, sep = "/")

table(rep_table$fam)
# How many elements are there in each Superfamily?

rep_table.m <- melt(rep_table)


# Arrange the data so that they are in the following order:
# LTR/Copia, LTR/Gypsy, all types of DNA transposons (TIR transposons), DNA/Helitron, all types of MITES
rep_table.m$fam <- factor(rep_table.m$fam, levels = c(
  "LTR/Copia", "LTR/Gypsy", "DNA/DTA", "DNA/DTC", "DNA/DTH", "DNA/DTM", "DNA/DTT", "DNA/Helitron",
  "MITE/DTA", "MITE/DTC", "MITE/DTH", "MITE/DTM",
  "DNA/CMC-EnSpm", "DNA/MULE-MuDR", "DNA/PIF-Harbinger", "DNA/hAT-Ac", "DNA/hAT-Tip100", "LINE/L1", "MITE/DTT", "RC/Helitron", "SINE/tRNA"
))

# NOTE: Check that all the superfamilies in your dataset are included above

rep_table.m$distance <- as.numeric(rep_table.m$variable) / 100 # as it is percent divergence

# Approximate divergence time in years: T = K / (2r), with K as a proportion.
# Course substitution rate: 8.22e-9 substitutions per site per year.
rep_table.m$age <- rep_table.m$distance / (2 * 8.22e-9)
write.table(
  rep_table.m,
  file = "/data/users/jli/genome_annotation_course/output/TE_divergence_age.tsv",
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)
# options(scipen = 999)

# remove helitrons as EDTA is not able to annotate them properly (https://github.com/oushujun/EDTA/wiki/Making-sense-of-EDTA-usage-and-outputs---Q&A)
rep_table.m <- rep_table.m %>% filter(!fam %in% c("DNA/Helitron","RC/Helitron"))

ggplot(rep_table.m, aes(fill = fam, x = distance, weight = value / 1000000)) +
  geom_bar() +
  cowplot::theme_cowplot() +
  scale_fill_viridis_d(option = "turbo") +
  xlab("Distance") +
  ylab("Sequence (Mbp)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 1, size = 9, hjust = 1), plot.title = element_text(hjust = 0.5))

ggsave(filename = "/data/users/jli/genome_annotation_course/plots/TE_landscape.pdf", width = 10, height = 5, useDingbats = F)



# Why is it important to have this plot in Mbp instead of counts?
# Hint:
# Consider a scenario where there is a lot of small fragments of TEs due to nested insertions and deletions.
# How would that affect the plot if you used counts instead of Mbp?
#
