
library(GENESPACE)
args <- commandArgs(trailingOnly = TRUE)
# get the folder where the genespace workingDirectory is located
wd <- args[1]
gpar <- init_genespace(wd = wd, path2mcscanx = "/usr/local/bin", nCores = 20)
# run genespace
out <- run_genespace(gpar)
pangenome <- query_pangenes(out,   bed = NULL,   refGenome = "TAIR10",   transform = TRUE,   showArrayMem = 
TRUE,   
# save pangenome object as rds
showNSOrtho = TRUE,   maxMem2Show = Inf)
saveRDS(pangenome, file = file.path(wd, "pangenome_matrix.rds"))