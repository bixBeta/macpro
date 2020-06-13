#!/usr/bin/env Rscript
args <-  commandArgs(trailingOnly = T)
pin <- args[1]
target <- read.table(args[2], header = T, sep = "\t", stringsAsFactors = F)

if (length(args)<=1) {
  print(" Usage = Rscript getCountMatrix.R  <pin> <targetFile>")  
  stop("Both arguments must be supplied!!! \n", call.=FALSE)
  
} 

rawDir = getwd()


loadCountData <- function(target, rawDir="raw", skip=0, featuresToRemove=c("alignment_not_unique", "ambiguous", "no_feature", "not_aligned", "too_low_aQual")){
  
  labels <- as.character(target[,1])
  files <- as.character(target[,2])
  
  # detect if input count files are from featureCounts or HTSeq-count
  f1 <- read.table(file.path(rawDir, files[1]), sep="\t", quote="\"", header=FALSE, skip=5, nrows=5, stringsAsFactors=FALSE)
  if (ncol(f1) >= 7 && is.numeric(f1[,7])){
    # counter featurecounts
    idCol <- 1
    countsCol <- 7
    header <- TRUE
  } else{
    if (ncol(f1) >= 2 && is.numeric(f1[,2])){
      # counter htseq-count
      idCol <- 1
      countsCol <- 2
      header <- FALSE
    } else{
      stop("Can't determine if count files come from HTSeq-count or featureCounts")
    }
  }
  
  rawCounts <- read.table(file.path(rawDir, files[1]), sep="\t", quote="\"", header=header, skip=skip, stringsAsFactors=FALSE)
  rawCounts <- rawCounts[,c(idCol, countsCol)]
  colnames(rawCounts) <- c("Id", labels[1])
  if (any(duplicated(rawCounts$Id))){
    stop("Duplicated feature names in ", files[1], ": ", 
         paste(unique(rawCounts$Id[duplicated(rawCounts$Id)]), collapse=", "))
  }
  cat("Loading files:\n")
  cat(files[1],": ",length(rawCounts[,labels[1]])," rows and ",sum(rawCounts[,labels[1]]==0)," null count(s)\n",sep="")
  
  for (i in 2:length(files)){
    tmp <- read.table(file.path(rawDir, files[i]), sep="\t", quote="\"", header=header, skip=skip, stringsAsFactors=FALSE)
    tmp <- tmp[,c(idCol, countsCol)]
    colnames(tmp) <- c("Id", labels[i])
    if (any(duplicated(tmp$Id))){
      stop("Duplicated feature names in ", files[i], ": ", 
           paste(unique(tmp$Id[duplicated(tmp$Id)]), collapse=", "))
    }
    rawCounts <- merge(rawCounts, tmp, by="Id", all=TRUE)
    cat(files[i],": ",length(tmp[,labels[i]])," rows and ",sum(tmp[,labels[i]]==0)," null count(s)\n",sep="")
  }
  
  rawCounts[is.na(rawCounts)] <- 0
  counts <- as.matrix(rawCounts[,-1])
  rownames(counts) <- rawCounts[,1]
  counts <- counts[order(rownames(counts)),]
  
  # check that input counts are integers to fit edgeR and DESeq2 requirements
  if (any(counts %% 1 != 0)) stop("Input counts are not integer values as required by DESeq2 and edgeR.")
  
  cat("\nFeatures removed:\n")
  for (f in setdiff(featuresToRemove,"")){
    match <- grep(f, rownames(counts))
    if (length(match)>0){
      cat(rownames(counts)[match],sep="\n")
      counts <- counts[-match,]
    }
  }
  
  cat("\nTop of the counts matrix:\n")
  print(head(counts))
  cat("\nBottom of the counts matrix:\n")
  print(tail(counts))
  return(counts)
}

rawCounts = loadCountData(target = target, rawDir = rawDir)


write.table(rawCounts, paste0(pin,"-countMatrix.txt"), sep = "\t", col.names = NA , quote = F)


