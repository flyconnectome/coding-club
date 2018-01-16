#Analysing which post-synaptic neurons share the same pre-synaptic connector.

library(elmr)
outgoing_connections <- function(skid, cut_point) {
  #get neuron of interest and find connectors in arbour of interest
  neuron = read.neuron.catmaid(skid)
  index = match(cut_point, neuron$d$PointNo)
  neuron.distal = distal_to(neuron, index)
  neuron.distal.points = neuron$d[neuron.distal,]
  #debug- graph to check selected distal points are in correct region
  nopen3d()
  plot3d(neuron, col = "gray23")
  points3d(neuron.distal.points[,c('X','Y','Z')], col = "deepskyblue")
  
  #select outgoing connectors in arbour of interest
  all_connectors <- catmaid_get_connectors_between(pre_skids = skid)
  connectors = all_connectors[all_connectors$pre_node_id %in% neuron.distal.points$PointNo,]
  #connectors <- distal_connectors[!duplicated(distal_connectors$connector_id), ]
  #debug - graph to check all selected connectors in correct region
  open3d()
  plot3d(neuron, col = "black")
  points3d(connectors[,c('connector_x','connector_y','connector_z')])
  
  return(connectors)
}

#get outgoing synapses 
neuron <- read.neuron.catmaid(2333007)
#tag neuron in CATMAID, distal to this node is your arbour of interest
cut_point <- neuron$tags$AJES_MVP2_axon_distal
n_connectors <- outgoing_connections(2333007, cut_point = cut_point)


######
#1. Using n_connectors df, For each connector_id count how many post_node_id occur. Label each count with the connector_id number
#2. Create a bar chart of each connector ID and the neuron identity of the post_node_ID. 
#3. Create an average connector_id graph

#1.
connectors <- unique(n_connectors$connector_id)
nprofiles <- lapply(c(1:length(connectors)), function(x) length(which(n_connectors$connector_id== connectors[x]))) #how many times connector id appears in collumn
names(nprofiles) <- connectors
barplot(t(sort(unlist(nprofiles))))

#2. 
outgoing_MVP2 <- n_connectors[,c(1, 2, 3)] #refers to pre_skid, post_skid and connector_id
outgoing_MVP2$outgoing_names <- catmaid_get_neuronnames(outgoing_MVP2$post_skid) #gets the names of the post-synaptic neurons
#How many specifc neuron type is connected to each connector_ID

col.names <- c("MVP2", "OAVPM", "APL", "KC", "other")
df <- data.frame(matrix(nrow = length(connectors), ncol = 5), row.names = connectors)
colnames(df) <- col.names

for(i in c(1:length(connectors))){
  x <- outgoing_MVP2[outgoing_MVP2$connector_id %in% connectors[[i]],]
  df$MVP2[[i]] <- length(grep(as.character("MBON-y1pedc>a/B 298954 JSL"), x$outgoing_names))
  df$OAVPM[[i]] <- length(grep(as.character("Putative OA-VPM3 2451279 PS - up-/downstream MVP2"), x$outgoing_names))
  df$APL[[i]] <- length(grep(as.character("APL"), x$outgoing_names))
  df$KC[[i]] <- length(grep(as.character("KC"), x$outgoing_names))
  df$other[[i]] <- length(grep(as.character("euron"), x$outgoing_names)) + length(grep(as.character("mbiguous"), x$outgoing_names)) + length(grep(as.character("DAN"), x$outgoing_names))
}

color <- c("darkgoldenrod1", "darkorchid1", "blue", "firebrick1", "lightblue2")
barplot(t(df), xlab = "Connector IDs", ylab = "No. of post-synaptic profiles", col = color, las = 2, cex.names = 0.7, main = "Downstream profiles of MVP2 axonal segment in y1/pedc")
legend(33, 12, legend = col.names, fill = color, cex = 0.75)


#3
mean <- unlist(lapply(c(1:ncol(df)), function(x) mean(df[,x])))
names(mean)<- col.names
barplot(mean, col = color, main = "Average downstream profiles of MVP2 axonal segment in y1/pedc")


