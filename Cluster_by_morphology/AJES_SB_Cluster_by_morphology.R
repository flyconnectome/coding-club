#Function that takes a dataset_annotation (ie. all neurons that you want to cluster)
#and colour by annotation (ie. which nodes you want to colour based on an annotation)
#returns a dendrogram with nodes coloured by annotation
cluster_function <- function(dataset_annotation, colour_by_annotation){
  library(catmaid)
  library(elmr)
  library(dendroextras)
  ns.dots <<- fetchdp_fafb(catmaid_skids(paste("annotation:^", dataset_annotation, "$", sep = "")))
  ns.matrix <<- nblast_allbyall(ns.dots)
  ns.clustered <<- nhclust(scoremat=ns.matrix)
  ns.clustered.dendro <<- as.dendrogram(ns.clustered)
  
  #change node colour to denote which lineage it belongs to
  skids <- as.numeric(labels(ns.clustered.dendro))
  df <- data.frame("skids"= skids, "annotation" = NA)
  for(i in 1:length(skids)){
    annotations <-catmaid_get_annotations_for_skeletons(skids[i])$annotation
    for(y in 1:length(colour_by_annotation)){
      if(any(annotations %in% colour_by_annotation[y])){
        df$annotation[i] <- colour_by_annotation[y]
      }}}
  
  df[is.na(df$annotation),]$annotation <- "No_annotation"
  df$label <- apply(df[,c(2,1)],1,paste, collapse = "--", sep = "")
  labels(ns.clustered.dendro) <- df$label
  annotations <<- sort(unique(df$annotation))
  
  #function to change colour of each node in dendrogram
  colLab <- function(n){
    if(is.leaf(n)){
      a <- attributes(n)
      color_pal <- rainbow(length(annotations))
      for(i in 1:length(annotations)){
        if(grepl(annotations[i], a$label)){
          attr(n, "nodePar") <- c(a$nodePar, list(lab.cex=.7,col=color_pal[i], pch=20 ))
        }
      }
    }
    return(n)
  }
  dL <- dendrapply(ns.clustered.dendro, colLab)
  labels(dL) <- skids
  dL <<- dL
  return(dL)
}

#assigning my arguments for the cluster_function
dataset_annotation <- "NAMK_DANs_all"
all_annotations <- catmaid_get_annotations_for_skeletons(catmaid_skids("annotation:NAMK_DANs_all"))
colour_by_annotation <- sort(unique(all_annotations$annotation[grep("NAMK_DANs_lin",all_annotations$annotation)]))

#dataset_annotation <- "FML - downstream of DA2"
#colour_by_annotation <- "FML - downstream of first DA2 - initial sample"
#other_annotation_label <- "second sample"

#This takes a while to run, but once the NBLAST is done it will save it as a variable.
col.dendro <- cluster_function(dataset_annotation = dataset_annotation, colour_by_annotation = colour_by_annotation)

#Plot the dendrogram using plot.dendrogram
par(xpd = F)
plot(dL, leaflab = "none", 
     main = "Neurons upstream of DANs clustered by morphology", 
     ylim = c(0,25), 
     xpd = FALSE)

legend("topright", 
       legend = annotations, 
       col = rainbow(length(annotations)),
       fil = rainbow(length(annotations)),
       pch = 20,
       cex = 0.75,
       ncol = 3)
#pch = c(20,20,4,4,4), bty = "n",  pt.cex = 1.5, cex = 0.8 , 
#text.col = "black", horiz = FALSE, inset = c(0.1, 0.1))

