synapses_per_neuropil <- function(skids = NULL, neurons, toFCWB = FALSE){#TODO - automatic skid/neuron detection?
  require(elmr)

  neuropils = FCWBNP.surf$RegionList
  
  if (missing(neurons)){
    #handle null skids
    neurons.fcwb = fetchn_fafb(skids, mirror = FALSE, reference = FCWB)
  }
  else{
    if (toFCWB == FALSE){
      neurons.fcwb = neurons
    }
    else{
      neurons.fcwb = xform_brain(neurons, sample = FAFB13, reference = FCWB)
    }
  }
  
  summaries = list()
  
  for (n in 1:length(neurons.fcwb)){
    neuron.fcwb = neurons.fcwb[[n]]
    
    neuron.outgoing = subset(neuron.fcwb$connectors, prepost == 0)
    neuron.incoming = subset(neuron.fcwb$connectors, prepost == 1)
    
    
    outgoing = sapply(neuropils, function(x){INTERNAL_count_synapses_in_mesh(neuron.outgoing, x)})
    incoming = sapply(neuropils, function(x){INTERNAL_count_synapses_in_mesh(neuron.incoming, x)})
    
    summary = data.frame(outgoing = outgoing, incoming = incoming)#neuropils given as row names from sapply
    summaries[[n]] = summary
  }
  
  return(summaries)
  
}

INTERNAL_count_synapses_in_mesh <- function(connectors, neuropil){
  tf = pointsinside(connectors[,c("x", "y", "z")], subset(FCWBNP.surf, neuropil))
  n = sum(tf, na.rm = TRUE)
  invisible(n)
}