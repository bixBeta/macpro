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
library(progress)

pb <- progress_bar$new(total = 100)


for (i in 1:20) {
  pb$tick()
  Sys.sleep(1 / 10)
}

# read mirdeep2 counts
counts = read.table(file = arg[1], header = T, comment.char = "", sep="\t")

PIN=strsplit(arg[1], split = ".csv")[[1]][1]

for (i in 1:30) {
  pb$tick()
  Sys.sleep(1 / 100)
}

colnames(counts)[1] = "X.miRNA"
newCounts = counts %>% select(!matches(c("read_count", "total", "precursor"))) %>%
  group_by(X.miRNA) %>% summarise(across(everything(), sum)) %>% column_to_rownames("X.miRNA")

newCounts = newCounts %>% mutate_all(round, 0)
newCounts.raw = newCounts %>% select(-matches("norm"))

system("mkdir rawCounts")

for (i in 1:ncol(newCounts.raw)) {
  xsub = newCounts.raw %>% select(all_of(i))
  write.table(xsub, file = paste0("rawCounts/", colnames(xsub), ".mirDeep2.rawCounts"),
              col.names = F, sep = "\t", quote = F)
}
for (i in 1:30) {
  pb$tick()
  Sys.sleep(1 / 100)
}


write.table(newCounts, paste0(PIN, "_MERGED.txt"), row.names = T, col.names = NA, quote = F, sep = "\t")

for (i in 1:20) {
  pb$tick()
  Sys.sleep(1 / 100)
}
