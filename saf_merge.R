#!/usr/bin/env Rscript

args <-  commandArgs(trailingOnly = T)

if (length(args)==0) {
  print(" Usage = Rscript saf_merge.R < safFile, sarFile or shinyCSV >")
  stop("Missing some files !!! \n", call.=FALSE)

}


suppressPackageStartupMessages(library("dplyr"))
saf.path <- args[1]
file.path <- args[2]

# saf.path <- "allSamplesMergedPeakset.Annotated.saf"
# file.path <- "itkTh17_vs_wtTh17.complete.txt"
# 
# 
# file.path <- "~/Downloads/itkTh17_vs_wtTh17.csv"
# 

### read in the saf file
safFile <- read.table(saf.path, header = T, sep = "\t")
colnames(safFile)[1] <- "peakID" 

if (grepl(".txt$", file.path)) {
  ### read in the sartools file 
  contrast <- read.table(file.path, header = T, sep = "\t")
} else {
  contrast <- read.csv(file.path, header = T, row.names = 1)
  colnames(contrast)[1] <- "Id" 
  
}

merged.results <- left_join(contrast, safFile, by = c("Id" = "peakID"))
merged.results <- merged.results %>% select("Chr","Start", "End", "Id", everything())
j = merged.results$Chr

merged.results$Chr <- paste0('chr', merged.results$Chr)

out.name <- strsplit(file.path, "\\.")[[1]][1]

write.csv(merged.results, paste0(out.name,".ANNOTATED.csv"), quote = F, row.names = F)
merged.results.bed <- merged.results  %>% select("Chr","Start", "End", "Id")
write.table(merged.results.bed, paste0(out.name,".homer.motif.input.bed"), quote = F, row.names = F, col.names = F, sep = "\t")
