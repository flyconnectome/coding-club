#When given a list of skids ('neurons'), returns a data frame of all neuropils with the number of synapses (connectors) in that
#neuropil contributed by each neuron

neuropils_innervated <- function(neurons) {
  #get names of neurons
  names <- catmaid_get_neuronnames(neurons)
  #fetch neurons in FCWB space
  neurons <- fetchn_fafb(neurons, mirror=F, reference = FCWB)
  #get list of connectors for the neurons
  connectors <- lapply(neurons, function(x) {x$connectors[,c('x','y','z')]})
  names(connectors) <- names

  #get number of connectors in each neuropil for each neuron
  synapse_numbers <- lapply(connectors,synapses_by_neuropil)

  #create data frame for result
  synapse_neuropil <- as.data.frame(matrix(0, ncol = length(synapse_numbers), nrow = 75))
  row.names(synapse_neuropil) <- names(synapse_numbers[[1]])
  names(synapse_neuropil) <- names

  #Put numbers of connectors in each neuropil into data frame
  for (i in 1:length(synapse_numbers)) {
    synapse_neuropil[,i] <- unlist(synapse_numbers[[i]])
  }
  
  #graphs to check number of synapses in each region; requires another function 'plot_connectors' which is on my github
  # nopen3d()
  # lapply(names(neurons), plot_connectors, colour='purple', reference='FCWB')
  # #plot3d(FCWB, alpha=0.2)
  # plot3d(subset(FCWBNP.surf,'SIP_L'),alpha=0.2, col='red')
  

  return(synapse_neuropil)

}

#function takes 'connectors' -  a dataframe of 3 columns which are the x, y and z coordinates of connectors -
#and returns a list of number of connectors by neuropil
synapses_by_neuropil <- function(connectors) {
  neuropils <- names(FCWBNP.surf$Regions)
  synapses <- lapply(neuropils, function (x) {sum(pointsinside(connectors,subset(FCWBNP.surf,x)))})
  names(synapses) <- neuropils
  return(synapses)
}

