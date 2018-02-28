#Function to return the incoming connectors of a neuron, distal or proximal to a given cut point

incoming_connections_direction <- function(skid, cut_point, direction = c("distal","proximal")) {
  neuron = read.neuron.catmaid(skid)
  #Get soma tag
  soma = neuron$tags$soma
  #Convert
  soma_index = match(soma, neuron$d$PointNo)
  index = match(cut_point, neuron$d$PointNo)
  
  #Find all points distal to the soma
  neuron.distal.soma = distal_to(neuron, soma_index)
  #Find all points distal to the cut point
  neuron.distal.cut_point = distal_to(neuron, index)
  
  #Find the points that are distal to the soma, which are not in distal to the cut point (i.e. proximal)
  neuron.proximal = setdiff(neuron.distal.soma, neuron.distal.cut_point)
  
  
  neuron.distal.points = neuron$d[neuron.distal.cut_point,]
  neuron.proximal.points = neuron$d[neuron.proximal,]
  
  #Find all connectors
  all_connectors <- catmaid_get_connectors_between(post_skids = skid)
  
  #distal_connectors
  distal_connectors = all_connectors[all_connectors$post_node_id %in% neuron.distal.points$PointNo,]
  
  #proximal_connectors
  proximal_connectors = all_connectors[all_connectors$post_node_id %in% neuron.proximal.points$PointNo,]
  
  if (direction == "distal") {
    nopen3d()
    plot3d(neuron, col = "gray23")
    points3d(neuron.distal.points[,c('X','Y','Z')], col = 'deepskyblue')
    
    nopen3d()
    plot3d(neuron, col = "black")
    points3d(distal_connectors[,c('connector_x','connector_y','connector_z')])
    
    return(distal_connectors)
    
  }else if (direction == "proximal") {
    nopen3d()
    plot3d(neuron, col = "black")
    points3d(neuron.proximal.points[,c('X','Y','Z')], col = 'deepskyblue')
    
    nopen3d()
    plot3d(neuron,col = "black")
    points3d(proximal_connectors[,c('connector_x','connector_y','connector_z')])
    
    return(proximal_connectors)
  }else return("You need to specify a direction!")
}