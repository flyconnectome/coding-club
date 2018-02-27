#R club: Identify interneurons downstream and upstream of given neurons.

#Working:
#Search all skids downstream of given neurons.
catmaid_get_connectors_between(pre_skids = 2109445)$post_skid
length(catmaid_get_connectors_between(pre_skids = 2109445)$post_skid)
#Use unique (or duplicated) function
unique(catmaid_get_connectors_between(pre_skids = 2109445)$post_skid)
length(unique(catmaid_get_connectors_between(pre_skids = 2109445)$post_skid))

post_synaptic_skids <- unique(catmaid_get_connectors_between(pre_skids= c(2109445))$post_skid)
pre_synaptic_skids <- unique(catmaid_get_connectors_between(post_skids= c(3026119))$pre_skid)
post <- c(1,2,3,4,5,6)
pre <- c(1,4,7,8,9)
match(post, pre)
post %in% pre
intersect(post, pre)

####Useable function:####ß
interneurons <- function(skids_upstream, skids_downstream){
  post_synaptic_skids <- unique(catmaid_get_connectors_between(pre_skids = skids_upstream))$post_skid
  pre_synaptic_skids <- unique(catmaid_get_connectors_between(post_skids = skids_downstream))$pre_skid
  interneurons <- intersect(post_synaptic_skids, pre_synaptic_skids)
  return(interneurons)
}

skids_upstream <- catmaid_skids("annotation:^AJES_all_y5PAMs_all_upstream$")
skids_downstream <- catmaid_skids("annotation:^NAMK_putative_PAM-y5_RIGHT$")
inter_skids <- interneurons(skids_upstream = skids_upstream, skids_downstream = skids_downstream)

#####Add another layer of connectivity#####
interneurons <- function(skids_upstream, skids_downstream){
  post_synaptic_skids <- unique(catmaid_get_connectors_between(pre_skids = skids_upstream)$post_skid)
  post_synaptic_skids_layer2 <- unique(catmaid_get_connectors_between(pre_skids = post_synaptic_skids)$post_skid)
  
  pre_synaptic_skids <- unique(catmaid_get_connectors_between(post_skids = skids_downstream)$pre_skid)
  pre_synaptic_skids_layer2 <- unique(catmaid_get_connectors_between(post_skids = pre_synaptic_skids)$pre_skid)
  interneurons_layer1 <- intersect(post_synaptic_skids, pre_synaptic_skids)
  interneurons_layer2 <- intersect(post_synaptic_skids_layer2, pre_synaptic_skids_layer2)
  
  list<- list("layer1" = interneurons_layer1, "layer2" = interneurons_layer2)
  return(list)
}
inter_skids <- interneurons(skids_upstream = skids_upstream, skids_downstream = skids_downstream)

#####Add how many synapses there are between pre and post, (only for layer 1)####

catmaid_get_connectors_between(post_skids =  inter_skids$layer1, pre_skids = skids_upstream)
nrow(catmaid_get_connectors_between(post_skids =  inter_skids$layer1, pre_skids = skids_upstream))
#Number of synapses that occur between given upstream skids and calculated downstream interneurons
synapse_no_upstream <- unlist(lapply(c(1:length(inter_skids$layer1)), function(x) length(which(catmaid_get_connectors_between(
  post_skids =  inter_skids$layer1, pre_skids = skids_upstream)$post_skid %in% inter_skids$layer1[x] == TRUE))))
synapse_no_downstream <- unlist(lapply(c(1:length(inter_skids$layer1)), function(x) length(which(catmaid_get_connectors_between(
  pre_skids =  inter_skids$layer1, post_skids = skids_downstream)$pre_skid %in% inter_skids$layer1[x] == TRUE))))
df_layer1 <- as.data.frame(cbind("Layer1_skids"= inter_skids$layer1, synapse_no_upstream, synapse_no_downstream))

interneurons <- function(skids_upstream, skids_downstream){
    post_synaptic_skids <- unique(catmaid_get_connectors_between(pre_skids = skids_upstream)$post_skid)
    post_synaptic_skids_layer2 <- unique(catmaid_get_connectors_between(pre_skids = post_synaptic_skids)$post_skid)
    
    pre_synaptic_skids <- unique(catmaid_get_connectors_between(post_skids = skids_downstream)$pre_skid)
    pre_synaptic_skids_layer2 <- unique(catmaid_get_connectors_between(post_skids = pre_synaptic_skids)$pre_skid)
    interneurons_layer1 <- intersect(post_synaptic_skids, pre_synaptic_skids)
    interneurons_layer2 <- intersect(post_synaptic_skids_layer2, pre_synaptic_skids_layer2)
    
    catmaid_get_connectors_between(post_skids =  interneurons_layer1, pre_skids = skids_upstream)
    nrow(catmaid_get_connectors_between(post_skids =  interneurons_layer1, pre_skids = skids_upstream))
    #Number of synapses that occur between given upstream skids and calculated downstream interneurons
    synapse_no_upstream <- unlist(lapply(c(1:length(interneurons_layer1)), function(x) length(which(catmaid_get_connectors_between(
      post_skids =  interneurons_layer1, pre_skids = skids_upstream)$post_skid %in% interneurons_layer1[x] == TRUE))))
    synapse_no_downstream <- unlist(lapply(c(1:length(interneurons_layer1)), function(x) length(which(catmaid_get_connectors_between(
      pre_skids =  interneurons_layer1, post_skids = skids_downstream)$pre_skid %in% interneurons_layer1[x] == TRUE))))
    
    neuron_name <- unlist(lapply(c(1:length(interneurons_layer1)), function(x) catmaid_get_neuronnames(interneurons_layer1)[[x]]))
    df_layer1 <- as.data.frame(cbind("Neuron_name" = neuron_name, "Layer1_skids"= interneurons_layer1, synapse_no_upstream, synapse_no_downstream))
    list<- list("df_layer1" = df_layer1, "layer2" = interneurons_layer2)
    return(list)
}
  
inter_skids_synapse_no <- interneurons(skids_upstream = skids_upstream, skids_downstream = skids_downstream)
#M6 upstream and all y5 PAMs downstream
M6_y5PAM <- interneurons(skids_upstream = 2109445, skids_downstream = skids_downstream)


#Add which connected neurons each synapse no. corresponds to? 
#Or does this make it too complicated as may be repeating interneurons more than once in list? 
