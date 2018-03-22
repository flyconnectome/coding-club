#check for indirect connections between two (or more) neurons
neurons_between <- function(pre, post, directional = TRUE, jumps = 1){
  #TODO - handle groups (e.g. PN type)
  # pre = read.neuron.catmaid(pre)
  # post = read.neuron.catmaid(post)
  prepost = read.neurons.catmaid(c(pre, post))
  
  connectors = connectors(prepost)$connector_id
  connectors.skids = catmaid_get_connectors(connectors)
  
  all_skids = c(connectors.skids$pre, connectors.skids$post)
  all_skids.2plus = unique(all_skids[duplicated(all_skids)])
  
  all_skids.2plus.interneuron = sapply(all_skids.2plus, 
                                       function(s){ (nrow(connectors.skids[connectors.skids$pre == pre & connectors.skids$post == s,]) > 0) & (nrow(connectors.skids[connectors.skids$pre == s & connectors.skids$post == post,]) > 0)
                                       })
  interneurons = !(all_skids.2plus[all_skids.2plus.interneuron] %in% c(pre, post)) 
  
  return(all_skids.2plus[all_skids.2plus.interneuron][interneurons])
} 