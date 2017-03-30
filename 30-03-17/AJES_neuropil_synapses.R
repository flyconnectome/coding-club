#Develop a function that, when given a neuron or neuronlist, will return a data frame of all 
#the neuropils in the fly brain with the number of synapses in that neuropil given by each neuron.

neuropil_synapses <- function(skid) {
  #Read neuron to fafb space
  n <- fetchn_fafb(skid)[[1]]
  print(head(n))
  #Determine the 3d points of both incoming and outgoing connectors
  incoming_connectors <- subset(connectors(n), prepost==1)
  outgoing_connectors <- subset(connectors(n), prepost==0)
  print(head(incoming_connectors))
  print(head(outgoing_connectors))
  #Get the names of all the neuropils in a list to use next
  neuropil<-names(FCWBNP.surf$Regions)
  
  #Function to find all the incoming connector points that are inside each neuropil
  incoming_func <- function(x) {
    pointsinside(incoming_connectors, FCWBNP.surf, x)
  }
  #Goes through each neuropil to give TRUE when a incoming connector lies in a given neuropil
  incoming_synapse_overlap <- sapply(neuropil, incoming_func)
  
  #Number of times this overlap occurs
  incoming_synapses<-colSums(incoming_synapse_overlap)
  
  #Now do the same for outgoing synapses
  outgoing_func <- function(x) {
    pointsinside(outgoing_connectors, FCWBNP.surf, x)
  }
  outgoing_synapse_overlap <- sapply(neuropil, outgoing_func)
  outgoing_synapses<-colSums(outgoing_synapse_overlap)
  
  #Now make this into a dataframe
  outgoing_dataframe<-as.data.frame(outgoing_synapses)
  incoming_dataframe<-as.data.frame(incoming_synapses)
  Synapses_in_neuropils_df<-cbind(outgoing_dataframe, incoming_dataframe)
  View(Synapses_in_neuropils_df)
}
