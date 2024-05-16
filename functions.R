#> Funtions for Ratio/Paired Analysis ----
#> 
#> 

#> Subsetting Normalized counts based on density distributions ----

extract.filter.normCounts = function(dds){
  
  # extract coldata
  meta.data = colData(dds) %>% data.frame()
  
  # add enid.id column for grepping later
  
  # meta.data$orig.ident = paste0("X", meta.data$label)
  # meta.data$orig.ident = gsub(pattern = "-", replacement = ".", x = meta.data$orig.ident)
  colnames(meta.data)[which(colnames(meta.data)== 'sampleID')] <- 'orig.ident'
  meta.data$enid.id = paste0(meta.data$orig.ident, "_", meta.data$enid)
  meta.data$orig.ident = str_replace(meta.data$orig.ident, pattern = "-", replacement = ".")
  # extract normalized counts
  norm.counts = counts(dds, normalized = T) %>% data.frame()
  
  # add row medians to norm.counts
  norm.counts$row.medians = apply(X = norm.counts, MARGIN = 1, FUN = median)
  
  # get the quantile profile of the median
  q.tile = quantile(norm.counts$row.medians)
  
  # bins.quantiles(norm.counts$row.medians, target.bins = 4, max.breaks = 15)$binct
  q.tile[4] <- 10
  q75.filtered.norm.counts = norm.counts[norm.counts$row.medians > q.tile[4], ]
  
  
  
  # plot norm counts pre and post filter
  
  counts.df.no.filter = norm.counts %>% select(-row.medians)
  counts.df.stacked.no.filter = stack(counts.df.no.filter)
  gg.df.no.filter = left_join(counts.df.stacked.no.filter, meta.data, by = c("ind" = "orig.ident"))
  
  p.pre.filter <- ggplot(gg.df.no.filter, aes(x=.data$values+1)) +
    stat_density(aes(group=.data$ind, color=ind), position="identity", geom="line", show.legend=TRUE) +
    scale_x_continuous(trans = log10_trans(),
                       breaks = trans_breaks("log10", function(x) 10^x),
                       labels = trans_format("log10", math_format(~10^.x))) +
    #labs(color="") +
    xlab(paste0("normCounts_", deparse(substitute(dds)))) +
    ylab("Density") +
    ggtitle("Density of counts distribution") +
    theme_classic() 
  
  
  counts.df.post.filter = q75.filtered.norm.counts %>% select(-row.medians)
  counts.df.stacked.post.filter = stack(counts.df.post.filter)
  gg.df.post.filter = left_join(counts.df.stacked.post.filter, meta.data, by = c("ind" = "orig.ident"))
  
  p.post.filter <- ggplot(gg.df.post.filter, aes(x=.data$values+1)) +
    stat_density(aes(group=.data$ind, color=ind), position="identity", geom="line", show.legend=TRUE) +
    scale_x_continuous(trans = log10_trans(),
                       breaks = trans_breaks("log10", function(x) 10^x),
                       labels = trans_format("log10", math_format(~10^.x))) +
    #labs(color="") +
    xlab(paste0("normCounts_", deparse(substitute(dds)), "__", "Row_median >", round(q.tile[4], 2))) +
    ylab("Density") +
    ggtitle("Density of counts distribution") +
    theme_classic() 
  
  
  
  #return(p.pre.filter)
  return(list(colData = meta.data,
              norm.counts.No.filter = norm.counts,
              Quantile = q.tile,
              q75.filtered.norm.counts  = q75.filtered.norm.counts,
              ggplots = 
                list(ggplot.pre.filter = p.pre.filter,
                     ggplot.post.filter = p.post.filter)
              
  )
  )
  
}


#> Compute Ratios for log2FC on geomMeans calculations ----

getRatios = function(cluster){
  
  metadata = cluster[["colData"]] %>% data.frame()
  metadata$enid.id =  paste0(metadata$orig.ident,"_",metadata$enid, "_",metadata$day)
  
  id = (which(table(metadata$enid) %% 2 == 0 ))
  
  metadata = metadata |> filter(enid %in% names(id))
  
  filtered.counts = cluster[["q75.filtered.norm.counts"]] %>% data.frame() %>% select(-row.medians)
  filtered.counts = filtered.counts |> select(all_of(metadata$orig.ident))
  
  # return(filtered.counts %>% head()) 
  colnames(filtered.counts) <- metadata$enid.id
  
  meta.filter.day1 = metadata %>% filter(day == "D1pre") %>% select(orig.ident)
  meta.filter.day2 = metadata %>% filter(day == "D2pre") %>% select(orig.ident)
  
  d1 = unname(unlist(meta.filter.day1))
  d2 = unname(unlist(meta.filter.day2))
  
  counts.day1 = filtered.counts %>% rownames_to_column("gene") %>% select(matches("D1pre"), "gene") %>% column_to_rownames("gene")
  counts.day2 = filtered.counts %>% rownames_to_column("gene") %>% select(matches("D2pre"), "gene") %>% column_to_rownames("gene")
  
  counts.day1 = counts.day1 + 0.1
  counts.day2 = counts.day2 + 0.1
  
  enids = unique(metadata$enid)
  ratios = list()
  
  for (i in 1:length(enids)) {
    
    ratios[[i]] <- as.data.frame(counts.day2[,grep(enids[i], colnames(counts.day2))]  / counts.day1[,grep(enids[i], colnames(counts.day1))])
    
    names(ratios)[[i]] <- enids[i]
    
    rownames(ratios[[i]]) <- rownames(counts.day2)
    
    colnames(ratios[[i]]) <- enids[i]
    
  }
  
  ratios.matrix =  as.matrix(do.call(cbind, ratios))
  log10.ratios.matrix = log10(ratios.matrix)
  
  return(list(D1 = counts.day1,
              D2 = counts.day2, 
              raw.ratios.list = ratios,
              non.log.ratios = ratios.matrix,
              log.10.ratios = log10.ratios.matrix,
              colData = metadata))
}


#> Compute PCA on the ratios ----

getPCA_ratios = function(cluster_){
  
  
  meta = cluster_$colData |> select(enid, condition) |> unique()
  rownames(meta) <- meta$enid
  
  
  pca = prcomp(t(cluster_$non.log.ratios))
  
  percentVar <- pca$sdev^2 / sum( pca$sdev^2 )
  pVar.df <- as.data.frame(percentVar)
  pVar.df$x = as.factor(paste0("PC",rownames(pVar.df)))
  
  pVar.df = pVar.df[ , order(names(pVar.df))]
  pVar.df$percentVar = pVar.df$percentVar * 100
  pVar.df$percentVar = round(pVar.df$percentVar, digits = 2)
  
  
  d <- data.frame(pca$x, name=rownames(pca$x))
  d2 <- left_join(d, meta, by = c("name" = "enid" ))
  
  
  return(list(
    pca_ratios = pca,
    pVar.df = pVar.df,
    colData_ratio = meta,
    pcaDF = d2
  ))
  
  
  
  
}

#> Plotting function for ratio pcas ----

plot_pca_ratios = function(x){
  
  df = x$pcaDF
  #df$batch = c(rep("1", 4), rep("2",4))
  ggplot(df, aes(x = PC1, y = PC2, color = name, shape = condition)) +
    geom_point(size = 4, alpha = 0.8) + theme_linedraw() +  scale_color_manual(values = turbo(8)) +
    xlab(paste0("PC1: ", x$pVar.df[levels(x$pVar.df$x) == "PC1",]$percentVar, " %" )) +
    ylab(paste0("PC2: ", x$pVar.df[levels(x$pVar.df$x) == "PC2",]$percentVar, " %" )) + geom_jitter() +
    stat_density2d(color = "gray", linewidth = 0.4, alpha = 0.4)
  
}


#> compute geometric means

getGeomMeansFC = function(xl_){
  
  matrix_ = xl_$non.log.ratios
  meta_ = xl_$colData
  
  # sep case and ctrl enids into their own data-frames
  case.enids = unname(unlist(metadata %>% filter(condition == "ME") %>% select(enid))) |> unique()
  ctrl.enids = unname(unlist(metadata %>% filter(condition == "HC") %>% select(enid))) |> unique()
  
  caseMatrix = matrix_ |> as.data.frame() |> select(matches(case.enids))
  
  caseMatrix$geomMean.cases =  apply(X = caseMatrix, MARGIN = 1, FUN = geometric.mean)
  
  ctrlMatrix = matrix_ |> as.data.frame() |> select(matches(ctrl.enids))
  
  ctrlMatrix$geomMean.ctrls =  apply(X = ctrlMatrix, MARGIN = 1, FUN = geometric.mean)
  
  # compute log2FC b/w cases and ctrls
  log2FC.geomMean = log2(caseMatrix$geomMean.cases) - log2(ctrlMatrix$geomMean.ctrls)
  
  names(log2FC.geomMean) <- rownames(ctrlMatrix)
  
  log2FC.geomMean = sort(log2FC.geomMean, decreasing = T)
  
  return(list(
    colData = meta_,
    case.matrix = caseMatrix,
    ctrl.matrix = ctrlMatrix,
    log2FC.geomMean = log2FC.geomMean
    
  ))
}


#> Run GSEA ---- 

runGSEA = function(cl_){
  
  rank.list = cl_$log2FC.geomMean
  
  gse = list()
  
  for (db in database) {
    gse[[db]] <-  GSEA(rank.list, TERM2GENE = database_list[[db]], pAdjustMethod = "BH", pvalueCutoff = 1)
  }
  
  return(list(
    
    rankList = rank.list,
    gseaResults = gse
    
  ))

  
}


#> DESeq2 results contrasts ----

getContrast = function(dds_){
  
  # requires contrast data.frame
  
  contrasts_ = list()
  for (i in 1:nrow(contrasts)) {
    
    contrasts_[[i]] <- results(dds_, contrast = c("phenoDay", contrasts$num[i], contrasts$denom[i]), alpha = 0.05)
    names(contrasts_)[[i]] <- paste0(contrasts$num[i],"_vs_", contrasts$denom[i])
    
    }
  
  return(contrasts.res = contrasts_)
  
}
