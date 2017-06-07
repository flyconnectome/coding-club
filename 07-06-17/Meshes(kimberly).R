#some neurons downstream of aSPg
downstreams <- read.neurons.catmaid('annotation:^aSP-g downstream \\(4\\)$')
#some DA1s that lie outside the area of interest
not_in_there <- read.neurons.catmaid(c(27295, 57311, 57323))
#put these together in one neuron list
all <-c(downstreams,not_in_there)

#read an aSPg
aSPg <- read.neuron.catmaid(2477473)

#get the arbor of the aSPg interested in
index = match(4236798, aSPg$d$PointNo)
neuron.distal = distal_to(aSPg, index)
neuron.distal.points = aSPg$d[neuron.distal,]

#make an alphashape of it
alphashape = alphashape3d::ashape3d(as.matrix(neuron.distal.points[,c('X','Y','Z')]), 
                                    alpha = 10000)
plot(alphashape)

#check if neurons have points in the mesh (takes a neuronlist, returns TRUE/FALSE for each)
in_there <- function(neuronlist,alphashape) {
  yay <- sapply(neuronlist, function(x) {if (sum(inashape3d(alphashape, points = xyzmatrix(x)))>0) 
  {return(TRUE)} else
  {return(FALSE)}})
  return(yay)
}

in_there(all,alphashape)
#returns true for the downstreams and false for the DA1s as expected (issue of just made mesh with points, so downstream targets that connect to points that make up the outside
#will return false as the connectors will lie outside. If wanted to include these would need to make a mesh that includes connectors / post_nodes / pre_nodes in it, wouldn't be
#too hard to do)