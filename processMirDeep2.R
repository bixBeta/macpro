#!/usr/bin/env Rscript

arg <-  commandArgs(trailingOnly = T)

if (length(arg)==0) {
cat("\n")
  print(" Usage = Rscript processMirDeep2.R < mirdeep2 csv output >")
  cat("\n")
  stop("Please provide the mirdeep2 csv output file !!! \n", call.=FALSE)
cat("\n")
cat("\n")  
} 

suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tibble))
suppressPackageStartupMessages(library(dplyr))


# config file is optional atm
#config = read.table(file = "config.txt", header = F, sep = "\t")

# read mirdeep2 counts
counts = read.table(file = arg[1], header = T, comment.char = "", sep="\t")

PIN=strsplit(arg[1], split = ".csv")[[1]][1]

newCounts = counts %>% select(!matches(c("read_count", "total", "precursor"))) %>% 
  group_by(X.miRNA) %>% summarise(across(everything(), sum)) %>% column_to_rownames("X.miRNA")

newCounts = newCounts %>% mutate_all(round, 0)

write.table(newCounts, paste0(PIN, "_MERGED.txt"), col.names = NA, row.names = T, quote = F, sep = "\t")
