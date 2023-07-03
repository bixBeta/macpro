library(dplyr)
library(tibble)
f = list.files(pattern = "rawCounts$")

counts = list()
for (i in 1:length(f)) {
  counts[[i]] <- read.table(f[i], header = F, sep = "\t")
  names(counts)[[i]] <- f[i]
}

collapsed.counts = lapply(counts, function(x){
  x %>% group_by(V1) %>% summarise(across(everything(), sum)) 
})

for (i in 1:length(collapsed.counts)) {
  write.table(as.data.frame(collapsed.counts[[i]]), quote = F, 
              file = paste0(names(collapsed.counts)[i], ".Collapsed"), 
              sep = "\t", col.names = F, row.names = FALSE)
}
