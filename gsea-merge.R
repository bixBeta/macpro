#!/usr/bin/env Rscript

args <-  commandArgs(trailingOnly = T)

if (length(args)==0) {
  cat("\n")
  cat("________________________________________________________________\n")
  cat("     Usage = Rscript gsea-merge.R <pin> <countMatrix> \n")
  cat("________________________________________________________________\n")
  cat("\n")
  stop("Missing raw count matrix !!! \n", call.=FALSE)
  
}


suppressWarnings(suppressPackageStartupMessages(library(progress)))
pb <- progress_bar$new(total = 100)
cat("\n")

for (i in 1:20) {
  pb$tick()
  Sys.sleep(1 / 10)
}

pin = args[1]

#counts = read.delim("~/Downloads/rawCounts.txt", row.names = 1)
counts = read.delim(args[2], row.names = 1)

suppressWarnings(suppressPackageStartupMessages(library(tibble)))
counts = rownames_to_column(counts, "gene")


all.files = list.files(pattern = ".tsv$") 
# positive enrichment file -----------------------------------------------------
res.pos = read.delim(file = all.files[grep(all.files, pattern = "gsea_report_for_na_pos")])

suppressWarnings(suppressPackageStartupMessages(library(dplyr)))
res.pos.filt <- res.pos %>% filter(FDR.q.val < 0.05)
res.pos.filt <- res.pos.filt %>% select(NAME,FDR.q.val,FWER.p.val,SIZE)


# negative enrichment file -----------------------------------------------------
res.neg = read.delim(file = all.files[grep(all.files, pattern = "gsea_report_for_na_neg")])

res.neg.filt <- res.neg %>% filter(FDR.q.val < 0.05)
res.neg.filt <- res.neg.filt %>% select(NAME,FDR.q.val,FWER.p.val,SIZE)

# first db table ###########################################################
res.merged.01 <- rbind(res.pos.filt, res.neg.filt)

# gsea rank file ---------------------------------------------------------------
rnk = read.delim(file = list.files(paste0(getwd(), "/edb"), pattern = ".rnk$", full.names = T), header = F)
colnames(rnk) <- c("HUGO", "foldChange")

for (i in 1:20) {
  pb$tick()
  Sys.sleep(1 / 10)
}
# gsea results (pathways) ------------------------------------------------------
# gsea.files = list.files("./text format/", full.names = T,pattern = ".txt$")
# gsea.files = all.files[grep("^[[:upper:]].*tsv", all.files)]


gsea.files = list.files()[which(list.files() %in% paste0(levels(as.factor(res.merged.01$NAME)), ".tsv"))]


# import gsea.files as list  ####
y = lapply(gsea.files, read.delim)
names(y) = strsplit(basename(gsea.files), split = ".tsv")
y <- lapply(y, function(x) x %>% select(SYMBOL,RANK.IN.GENE.LIST,CORE.ENRICHMENT))

for (n in names(y)){
  y[[n]]['pathwayID'] = n
}

# second db table ####
y.all.02 = do.call(rbind, y)
for (i in 1:20) {
  pb$tick()
  Sys.sleep(1 / 10)
}

# GSEA RESULTS DB ####
DB.1 = left_join(res.merged.01,y.all.02,  by = c("NAME" = "pathwayID"))

# final table ####
DB.2 = full_join(DB.1, rnk, by = c("SYMBOL" = "HUGO"))



# INPUT FOR SHINY ####
shinyInput = left_join(counts, DB.2, by = c("gene" = "SYMBOL"))
shinyInput = shinyInput[!is.na(shinyInput$NAME),]
colnames(shinyInput)[which(colnames(shinyInput) == "NAME")] = "pathwayID"

write.table(shinyInput, paste0(args[1],".merged_gsea_normalized_counts.txt"), sep = "\t", col.names = T, quote = F, row.names = F)
for (i in 1:40) {
  pb$tick()
  Sys.sleep(1 / 10)
}
