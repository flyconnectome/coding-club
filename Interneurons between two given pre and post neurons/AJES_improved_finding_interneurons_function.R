#Function returns two layers of interneurons between upstream_skid(s) onto downstream skid(s)
#NB If the provided upstream skids are not indirectly upstream of your downstream skids returns NA.

bottom_layer_skids <- c(3026119, 5652208) #y5-PAM upstream neurons
top_layer_skids <- c(2333007, 2109445) #MBONs
#eg. I can use this function to find two layers of interneurons between MBONs onto y5-PAM upstream neurons
stream_function <- function(bottom_layer_skids, top_layer_skids){
  library(catmaid)
  first_layer_skids <- catmaid_get_connectors_between(post_skids = bottom_layer_skids)$pre_skid
  second_layer_con <- catmaid_get_connectors_between(post_skids = first_layer_skids)
  top_layer_con <- catmaid_get_connectors_between(post_skids = unique(second_layer_con$pre_skid))
  refined_top_layer_skids <- unique(top_layer_con$pre_skid[which(top_layer_con$pre_skid %in% top_layer_skids)])
  if(length(refined_top_layer_skids) == 0){
    pathway <- c(NA, NA, NA, NA)
    names(pathway) <- c("bottom_layer", "first_layer", "second_layer", "top_layer")
    return(pathway)
  }else{
    second_layer_skids <- catmaid_skids(unique(top_layer_con[top_layer_con$pre_skid %in% refined_top_layer_skids,]$post_skid))
    first_layer_skids <- catmaid_skids(unique(second_layer_con[second_layer_con$pre_skid %in% second_layer_skids,]$post_skid))
    
    refined_top_layer_names <- catmaid_get_neuronnames(refined_top_layer_skids)
    second_layer_names <- catmaid_get_neuronnames(second_layer_skids)
    first_layer_names <- catmaid_get_neuronnames(first_layer_skids)
    bottom_layer_names <- catmaid_get_neuronnames(bottom_layer_skids)
    
    pathway <- list(bottom_layer_names, first_layer_names, second_layer_names, refined_top_layer_names)
    names(pathway) <- c("bottom_layer", "first_layer", "second_layer", "top_layer")
    return(pathway)
  }
}
#Using function:
interneurons <- stream_function(bottom_layer_skids, top_layer_skids)
#View list of interneurons
interneurons$bottom_layer
interneurons$first_layer
interneurons$second_layer
interneurons$top_layer
#Get skids of these interneurons
skids <- as.numeric(unlist(lapply(1:3, function(x) names(interneurons[[x]]))))
#Use catmaid_set_annotations_for_skeletons to set annotations to these skids to make a connectivity diagram with

#Improve function if top_layer neurons are only directly upstream or upstream by one layer onto bottom_layer neurons