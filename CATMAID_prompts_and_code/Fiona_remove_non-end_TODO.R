#remove TODO tag from non-end nodes
catmaid_remove_traced_TODO <- function(skid){
  return = ""
  neuron = read.neuron.catmaid(skid)
  points = neuron$d
  points$index = 1:nrow(points)
  TODO = points[points$PointNo %in% neuron$tags$TODO,]
  TODO.to_remove = TODO[!TODO$index %in% neuron$EndPoints,]
  if (nrow(TODO.to_remove) < 1){ return = "There are no non-end TODO tags to remove" }
  else{ 
    results = lapply(TODO.to_remove$PointNo, 
                    function(node_id){ 
                      catmaid_fetch(paste0("/1/label/treenode/", node_id, "/remove"), body = list('tag'='TODO')) 
                    }
              )
    #check for any errors and report
    messages = ""
    for(r in results){
      if(r$message != "success"){
        messages = paste0(messages, attr(r, "url"), " - ", r$message, " \n")
      }
    }
    if(messages != ""){ return = paste0("There were some errors; see below\n",messages) }
    else{ return = paste0("Successfully removed ", length(r), " non-end TODO tags")}
  }
  return(return)
}