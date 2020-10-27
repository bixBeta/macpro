#!/usr/bin/env Rscript

args <-  commandArgs(trailingOnly = T)

if (length(args)==0) {
  print(" Usage = Rscript saf_merge.R < safFile >")
  stop("Missing some files !!! \n", call.=FALSE)
  
}
cat("\n")
library(progress)
pb <- progress_bar$new(total = 100)

for (i in 1:20) {
  pb$tick()
  Sys.sleep(1 / 10)
}


suppressWarnings(suppressPackageStartupMessages(library("dplyr")))
saf.path <- args[1]


# SAF ----------------------------------------------------------------------------------------


### read in the saf file
safFile <- read.table(saf.path, header = T, sep = "\t")
colnames(safFile)[1] <- "peakID" 


saf.bed <- safFile %>%
  select(2,3,4,1)

saf.bed$Chr <- paste0('chr', saf.bed$Chr)
write.table(saf.bed, "HOMER.MOTIF.INPUT.BED", quote = F, row.names = F, col.names = F, sep = "\t")

safFile = select(safFile, !contains(colnames(safFile)[c(6,7,9,14,15,17,18)]))


for (i in 1:30) {
  pb$tick()
  Sys.sleep(1 / 100)
}


# Merge Function ----------------------------------------------------------------------------

mergeFunc <- function(s = safFile, c = contrast){
  
  # combine saf file annotations with the contrast file
  merged.results <<- left_join(contrast, safFile, by = c("Id" = "peakID"))
  merged.results <<- merged.results %>% select("Chr","Start", "End", "Id", everything())
  merged.results$Chr <<- paste0('chr', merged.results$Chr)
  
  # filter out the down regulated regions and prepare bed file
  down.reg <<- merged.results %>% filter(log2FoldChange < 0, padj < 0.05) 
  down.reg.bed <<- down.reg %>% select("Chr","Start", "End", "Id")
  
  # filter out the up regulated refions and prepare bed file
  up.reg <<- merged.results%>% filter(log2FoldChange > 0, padj < 0.05)
  up.reg.bed <<- up.reg %>% select("Chr","Start", "End", "Id")
  
  # filter out all regions i.e. padj < 0.05 and prepare bed file
  complete <<- rbind(down.reg, up.reg)
  complete.bed <<- complete %>% select("Chr","Start", "End", "Id")
  
}




# Call Functions ---------------------------------------------------------------------------

file.path = list.files(path = getwd(), pattern = "_vs_", full.names = T)

for (i in 1:30) {
  pb$tick()
  Sys.sleep(1 / 100)
}


for (i in 1:length(file.path)) {
  
  if (grepl(".txt$", file.path[i])) {
    ### read in the sartools file 
    contrast <<- read.table(file.path[i], header = T, sep = "\t")
  } else {
    ### read in the shiny csv file
    contrast <<- read.csv(file.path[i], header = T, row.names = 1)
    colnames(contrast)[1] <- "Id" 
  }
  
  mergeFunc(s = safFile, c = contrast)
  
  out.name <<- strsplit(basename(file.path[i]), "\\.")[[1]][1]
  
  ### Write the merged annotated output to file
  write.table(merged.results, paste0(out.name,".RAW.ANNOTATED.txt"), sep = "\t", quote = F, row.names = F)
  ### Write complete bed regions to use with HOMER
  write.table(complete.bed, paste0(out.name,".COMPLETE.homer.bed"), quote = F, row.names = F, col.names = F, sep = "\t")
  
  ### Write up reg bed regions to use with HOMER
  write.table(up.reg.bed, paste0(out.name,".UP.homer.bed"), quote = F, row.names = F, col.names = F, sep = "\t")
  
  ### Write down reg bed regions to use with HOMER
  write.table(down.reg.bed, paste0(out.name,".DOWN.homer.bed"), quote = F, row.names = F, col.names = F, sep = "\t")
  
}


# organize outs
system("mkdir BEDS ANNOTS")
system("mv *.bed HOMER.MOTIF.INPUT.BED BEDS")
system("mv *.RAW.ANNOTATED.txt ANNOTS")
system("mkdir BEDS/COMPLETE BEDS/UP BEDS/DOWN")
system("mv BEDS/*.COMPLETE* BEDS/COMPLETE")
system("mv BEDS/*.UP* BEDS/UP")
system("mv BEDS/*.DOWN* BEDS/DOWN")

for (i in 1:20) {
  pb$tick()
  Sys.sleep(1 / 100)
}



