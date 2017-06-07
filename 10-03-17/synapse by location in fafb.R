#nopen3d() first!! then can call as many times as like to build up plot on top.
#shows position of synapses from particular specified neurons. Different shapes
#for input vs output. Colour by neuron - legend.

#inputs are seed (the skid of the neuron you want to see the synapse locations for) 
#and queries a vector of skids of neurons you want to see positions for 

seed=2333007
queries=c(1299740, 343928, 1298803)

synapse_by_location <- function(seed,queries) {
  #read seed neuron into catmaid
  neur <- fetchn_fafb(seed, mirror=FALSE)[[1]]
  #retrieve table of all connections downstream of the seed
  pre_synapses <- catmaid_get_connectors_between(pre_skids = seed)
  
  #Pull outgoing connectors
  fafb_conn_down <- subset(connectors(neur), prepost==0)
  
  #Want all the connector Ids for the given post synaptic skids.
  
  function1 <-function(x){
    fstep1 <- pre_synapses[pre_synapses$post_skid == x,]
  }
  step1 <-lapply(queries, function1)
  step2 <- lapply(step1, `[`, c('post_skid', 'connector_id'))  #Code i pinched off internet, not sure how/why it works
  
  
  
  #Make step2 into a data frame with 2 collumns post_skid and connector_id
  
  
  
  #Then add an extra collum which has extracted x,y,z collumns of fafb_conn_down for each connector_id
  
  

  
  
  
  
  
  
  
  
  
  function2 <- function(x){
    fstep2<- fafb_conn_down[fafb_conn_down$connector_id == x,]
  }

  step3<- lappl  

 points3d(step3[,c("x", "y", "z")], col = "cyan")
  
  
  plot3d(neur, col = 'black', soma=T)
  
  pop3d()
  
  
  
  #retrieve just the pre-synapses that involve query neurons
  pres <- lapply(queries, get_post_xyz, connectors= pre_synapses, prepost = 'pre')
  names(pres) <- queries
  
  #plot seed neuron in black with pre-synapses as points
  #colours are generated in order from a rainbow palette.
  plot3d(neur, col = 'black', soma=T)
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
  } else if (prepost == 'post') {
    xyz <- xyz[connectors$pre_skid == neuron,]
  }
  return(xyz)
}
