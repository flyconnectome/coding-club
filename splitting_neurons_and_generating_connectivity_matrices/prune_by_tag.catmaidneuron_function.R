prune_by_tag.catmaidneuron<- function(x, tag = "SCHLEGEL_LH", remove.upstream = TRUE){
  p = unlist(x$tags[names(x$tags)%in%tag])
  if(is.null(p)){
    stop(paste0("Neuron does not have a tag in: ",tag))
  }
  split.point = as.numeric(rownames(x$d[x$d$PointNo==p,]))
  n = nat::as.ngraph(x)
  leaves = nat::endpoints(x)
  downstream = suppressWarnings(unique(unlist(igraph::shortest_paths(n, split.point, to = leaves, mode = "out")$vpath)))
  pruned = nat::prune_vertices(x,verticestoprune = downstream, invert = remove.upstream)
  pruned$connectors = x$connectors[x$connectors$treenode_id%in%pruned$d$PointNo,]
  relevant.points = subset(x$d, PointNo%in%pruned$d$PointNo)
  y = pruned
  y$d = relevant.points[match(pruned$d$PointNo,relevant.points$PointNo),]
  y$d$Parent = pruned$d$Parent
  y
}

em.pns.termini = nat::nlapply(opns.em, prune_by_tag.catmaidneuron, remove.upstream = TRUE, tag = "SCHLEGEL_LH", OmitFailures = TRUE) 