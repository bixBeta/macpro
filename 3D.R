#!/usr/bin/env Rscript
args <-  commandArgs(trailingOnly = T)


# check for required argument
if (length(args)==0) {
  print("=======================================================")
  print(" Usage = Rscript 3D.R < PIN > < .Rdata file > ")  
  print("=======================================================")
  stop("Both arguments must be supplied!!! \n", call.=FALSE)
  
} 

PIN <- args[1]
load(args[2])

# write.table(counts, paste0(PIN, "_rawCounts.txt"), sep = "\t", quote = F)


# ################################
# ################################
# # DESEQ2
#
library("DESeq2")
library("dplyr")
library("tidyverse")
library("shiny")

#
## -------------------------------------------------------------------------------------------------------------------
dds <- DESeqDataSetFromMatrix(countData = counts,
                              colData = target,
                              design = ~ group)

#
#
#
# ## -------------------------------------------------------------------------------------------------------------------
dds <- DESeq(dds)
resultsNames(dds)
#
# ## -------------------------------------------------------------------------------------------------------------------
vsd <- varianceStabilizingTransformation(dds, blind=T)

#
# ## -------------------------------------------------------------------------------------------------------------------
rv <- rowVars(assay(dds))
# select 500 top genes by variance
select <- order(rv, decreasing=TRUE)[seq_len(min(500, length(rv)))]
# perform a PCA on the data in assay(x) for the selected genes
pca <- prcomp(t(assay(dds)[select,]))
#
# # the contribution to the total variance for each component
percentVar <- pca$sdev^2 / sum( pca$sdev^2 )
cond <- target$group
intgroup <- "group"
intgroup.df <- as.data.frame(colData(dds)[, intgroup, drop=FALSE])

#
# # assembly the data for the plot
d <- data.frame(PC1=pca$x[,1], PC2=pca$x[,2], group=cond, intgroup.df, name=colnames(dds))
d2 <- data.frame(PC1=pca$x[,1], PC3=pca$x[,3], group=cond, intgroup.df, name=colnames(dds))

# ## -------------------------------------------------------------------------------------------------------------------
#
PC1= as.data.frame(pca$x[,1])
PC2= as.data.frame(pca$x[,2])
PC3= as.data.frame(pca$x[,3])
#
pComp.df <- data.frame(PC1, PC2 , PC3)

pComp.df <- rownames_to_column(pComp.df, var = "samples")
pComp.df <- left_join(pComp.df, target, by = c("samples" = "label"))
pComp.df <- pComp.df %>% mutate_at(vars(matches("pca")), ~ ./100000)

hc2 <- hclust(dist(t(assay(vsd))), method="ward.D")


runApp("/Users/fa286/Desktop/app.R", launch.browser = T, port = 80)
