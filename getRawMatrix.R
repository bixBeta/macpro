#!/usr/bin/env Rscript

args <-  commandArgs(trailingOnly = T)
# check for required argument

if (length(args)==0) {
  print(" Usage = Rscript getRawMatrix.R < PIN >")
  stop("Missing PIN !!! \n", call.=FALSE)
  
}


library(progress)
pb <- progress_bar$new(total = 100)

for (i in 1:20) {
  pb$tick()
  Sys.sleep(1 / 10)
}


PIN = args[1]

count.Files.paths = list.files(pattern = ".rawCounts$", full.names = T)

count.Files = list()

for (i in 1:length(count.Files.paths)) {
  count.Files[[i]] <- read.table(count.Files.paths[i], sep = "\t", header = F)
  names(count.Files)[[i]] <- strsplit(basename(count.Files.paths)[i], split = ".ReadsPerGene.out.tab.rawCounts")[[1]]
}

for (i in 1:30) {
  pb$tick()
  Sys.sleep(1 / 100)
}

count.matrix = do.call(what = cbind, count.Files)
rownames(count.matrix) <- count.matrix[,1]

suppressPackageStartupMessages(library(dplyr))

count.matrix = count.matrix %>% select(!matches(".V1"))

x = colnames(count.matrix)
y = as.list(x)

z = lapply(y, function(x){
  strsplit(x , split = ".V")[[1]][1]
})

colnames(count.matrix) <- unlist(z)


write.table(count.matrix, file = paste0(PIN, "_rawCounts.txt"), sep = "\t", quote = F, col.names = NA)

for (i in 1:50) {
  pb$tick()
  Sys.sleep(1 / 100)
}