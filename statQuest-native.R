vsdm <- as.matrix(assay(vsd))
pca <- prcomp(t(vsdm), scale. = F)
plot(pca$x[,1],pca$x[,2])
pca$x

pca.var <- pca$sdev^2
pca.var.per <- round(pca.var/sum(pca.var)*100,1)
barplot(pca.var.per, main = "Scree Plot", xlab = "Principal Component", ylab = "Percent Variation")

pca.data  <- data.frame(Sample = rownames(pca$x), X = pca$x[,1], Y = pca$x[,2])
pca.data

ggplot(data = pca.data, 
       aes(x=X, y=Y, label = Sample)) + geom_text() + 
  xlab(paste("PC1 - ", pca.var.per[1], "%", sep="")) +
  ylab(paste("PC2 - ", pca.var.per[2], "%", sep="")) +
  theme_bw() +
  ggtitle("vsd - normalized")
pca$rotation


rv <- rowVars(assay(vsd))
# select the ntop genes by variance
select <- order(rv, decreasing=TRUE)[seq_len(min(500, length(rv)))]
pca <- prcomp(t(assay(vsd)[select,]))
pca.var <- pca$sdev^2
pca.var.per <- round(pca.var/sum(pca.var)*100,1)
barplot(pca.var.per, main = "Scree Plot", xlab = "Principal Component", ylab = "Percent Variation")

ggplot(data = pca.data, 
       aes(x=X, y=Y, label = Sample)) + geom_text() + 
  xlab(paste("PC1 - ", pca.var.per[1], "%", sep="")) +
  ylab(paste("PC2 - ", pca.var.per[2], "%", sep="")) +
  theme_bw() +
  ggtitle("vsd - normalized")
pca$rotation
