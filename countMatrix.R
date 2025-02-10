#!/usr/bin/env Rscript

args <-  commandArgs(trailingOnly = T)

# check for required argument
if (length(args)==0) {
  print("=======================================================")
  print(" Usage = Rscript countMatrix.R < PIN > ")  
  print("=======================================================")
  stop("Pin required", call.=FALSE)
  
} 


wd = getwd()
pin = args[1]

files = list.files(wd, full.names = T, pattern = "rawCounts$")

cl = list()

for (i in 1:length(files)) {
  
  cl[[i]] <- read.table(files[i], header = F, row.names = 1)
  names(cl)[i] <- basename(files)[i]
}

matrix = do.call(cbind, cl)
colnames(matrix) <- unlist(strsplit(basename(files), split = ".rawCounts"))


write.table(x = matrix, file = paste0(pin, ".rawCounts.txt"), sep = "\t", quote = F, col.names = NA, row.names = T)
