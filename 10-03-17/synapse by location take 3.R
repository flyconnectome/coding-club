#nopen3d() first!! then can call as many times as like to build up plot on top.
#shows position of synapses from particular specified neurons. Different shapes
#for input vs output. Colour by neuron - legend.

#inputs are seed (the skid of the neuron you want to see the synapse locations for) 
#and queries a vector of skids of neurons you want to see positions for 



synapse_by_location2 <- function(seed,queries) {
  #read seed neuron into catmaid
  neur <- read.neuron.catmaid(seed)
  #retrieve table of all connections downstream of the seed
  pre_synapses <- catmaid_get_connectors_between(pre_skids = seed)

  #retrieve just the pre-synapses that involve query neurons
  pres <- lapply(queries, get_post_xyz, connectors= pre_synapses, prepost = 'pre')
  names(pres) <- queries
 
    #plot seed neuron in black with pre-synapses as points and post-syanpses as stars
  #colours are generated in order from a rainbow palette.
  plot3d(neur, col = 'brown', soma=T)
  colours <- rainbow(length(queries))
  i=1
  for (var in pres) {
    points3d(var, col=colours[i], size=6)
    i = i + 1
  }
 
  
  #produce key for graph, showing which neurons are which colours
  heights <- rep(1,times=length(queries))
  key <- pie(heights,col=colours,labels = queries)
}

#neuron is the skid of the neuron you want the post xyz coordinates for,
#connectors is the dataframe made by the function
#catmaid_get_connectors_between for the seed neuron,
#prepost indicates if you're supplying the dataframe of 
#presynpases or postsynapses. enter pre or post.
#I chose post node xyz as if multiple neurons connect
#at the same synapse then this will allow symbols to not
#lie directly on top of eachother, unlike using the 
#connector xyz
get_post_xyz <- function(neuron, connectors, prepost) {
  xyz <- connectors[,c('post_node_x','post_node_y','post_node_z')]
  #print(str(xyz))
  if (prepost == 'pre') {
    xyz <- xyz[connectors$post_skid == neuron,]
  } 
  return(xyz)
}
synapse_by_location(seed, queries = queries)





#Plot neuropils on top
plot3d(FAFB13NP.surf, "SIP.R", alpha = 0.2, col= "grey")
plot3d(FAFB13NP.surf, "LH.R", alpha = 0.2, col= "grey")
pop3d()
clear3d()

V2a <- synapse_by_location2(346114, queries = queries)

