# Libraries
library(catmaid)
library(elmr)
library(dendextend)

# Data
skids = catmaid_skids("annotation:FML - downstream of DA2")         # skids of whole sample
S_1 = catmaid_skids("annotation:FML - downstream of first DA2")     # Initial sample
                                                # Binary colour code
# Neurons/nBlast
N_all = read.neurons.catmaid(skids)                                 # get neurons
N_all_dps = dotprops(N_all/1e3)                                     # Convert to dotprops
Blast = nblast_allbyall(N_all_dps,normalisation = 'mean')           # Pairwise nBlast
# Clustering/Dendrogram
Dend = as.dendrogram(nhclust(scoremat=Blast))                       # Cluster and Dendrogram

# function to apply to nodes
leaf_col<-function(n) {
  if(is.leaf(n)) {
    if(labels(n) %in% S_1) {
      attr(n, 'edgePar')$col = 'red'
    } else {
      attr(n, 'edgePar')$col = 'blue'
    }
  }
  return(n)
}

# dendrapply applies a function to each node in a dendrogram
dL = dendrapply(Dend, leaf_col)

# plot

plot(dL, 
     main = "DA2 Upstream",
     ylim = c(0,20))
# Add a legend
legend("topright", c("Sample 1","Sample 2"), fill=c("red","blue"), horiz=TRUE, cex=0.8)

# Alternative method

# get true/false list 
Bool = labels(Dend)%in%S_1
# convert list to colours
colour = c()
for (i in Bool) {
  if(i) {
    colour = c(colour, 'red')
  } else {
    colour = c(colour, 'blue')
  }
}
#names(colours) = labels(Dend)
colour = structure(colour, .Names = labels(Dend))
# use set_leaf_colours
dL2 = set_leaf_colours(Dend,colour,"edge")
# plot
plot(dL2,
     main = "DA2 Upstream",
     ylim = c(0,20))
legend("topright", c("Sample 1","Sample 2"), fill=c("red","blue"), horiz=TRUE, cex=0.8)
