gmr_scores <- function(annotation, resultsmat){
  # This function returns the relevant columns of an NBLAST-results matrix, given an annotation
  skids = catmaid_skids(paste("annotation:", annotation, sep="")) # use annotation to get a vector of skids
  scoremat = resultsmat[,colnames(resultsmat) %in% skids]  # use skids to get relevant columns of results matrix
  
  # terrible stuff to get the top 30 skeleton-GMR line matches out of the results matrix
  top30coords = t(apply(as.matrix(head(sort(scoremat, decreasing=TRUE), 30)), 1, function(x) which(scoremat==x,arr.ind=T)))[,c(2:1), drop = FALSE]
  top30matches = cbind(apply(as.matrix(top30coords[,1]), 1, function(x) colnames(scoremat)[x]), apply(as.matrix(top30coords[,2]), 1, function(x) rownames(scoremat)[x]))
  
  return(top30matches)
}