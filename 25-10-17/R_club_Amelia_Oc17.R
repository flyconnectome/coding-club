#The number of synapses plotted as a function from the putative spike initiation zone of a neuron's dendrites,
#ie. the point where the dendrites become a single axonal fiber.

#Ensure "spike initiation zone" node is tagged with AJES_dendrites_distal before using function and soma is rooted in CATMAID.

#skid = 2109445
#input.skid = 2333007


synapse_distance <- function(skid, input.skid){
  n = read.neuron.catmaid(skid)
  root = n$tags$AJES_dendrites_distal
  #create an ngraph of neuron
  #"the ngraph class contains a (completely general) graph representation of a neuron's connectivity in an igraph object."
  ng = as.ngraph(n, weights = T)
  #Get information about all pre-synaptic neurons of n.
  neuron_data <-catmaid_get_connectors_between(post_skids = skid)
  #Select inputs that are only from inpur.skid
  n.inputs <- neuron_data[neuron_data$pre_skid %in% input.skid,]
  #Get the post_node_ids of these connections 
  n_post_nodes <- n.inputs$post_node_id
  #Get vertex indices, returns vector of positions of matches of its argument in its second argument. 
  vids <- lapply(n_post_nodes, function(x) match(x, n$d$PointNo))
  refvid <- match(root, n$d$PointNo)
  library(igraph)
  #Calculate distances of each input (x) from spike initiation zone (refvid), within the neuron graph (ng).
  dist_raw <- lapply(vids, function(x) distances(ng, x, refvid))
  #Change to um, numeric and rounded number.
  dist <- round(as.numeric(as.matrix(dist_raw))/1000)
  #Make data frame of post_node_ID and distance
  df <- data.frame(n_post_nodes, "distance" = as.matrix(dist))
  #Range of inputs to create x-axis, taken from maximum distance of non-MVP2 inputs
  range <- c(1:150)
  #Creates points to plot on x-axis
  freq.mat <- as.matrix(lapply(range, function(x) sum(df$distance == x)))
  freq.df <- data.frame("freq" = as.numeric(freq.mat), "distance" = range)
  # norm <- function(x) {
  #  return ((x - min(x)) / (max(x) - min(x))) }
  #final_df <- as.data.frame(lapply(freq.df, norm))
  freq.df[freq.df$freq == 0,] <- NA
  return(freq.df)
}

#Non-MVP2 inputs
anti_synapse_distance <- function(skid, input.skid){
  n = read.neuron.catmaid(skid)
  root = n$tags$AJES_dendrites_distal
  ng = as.ngraph(n, weights = T)
  neuron_data <-catmaid_get_connectors_between(post_skids = skid)
  #Note in the next line the addition of "!" to get all input synapses NOT from MVP2
  n.inputs <- neuron_data[!neuron_data$pre_skid %in% input.skid,]
  n_post_nodes <- n.inputs$post_node_id
  vids <- lapply(n_post_nodes, function(x) match(x, n$d$PointNo))
  refvid <- match(root, n$d$PointNo)
  library(igraph)
  dist_raw <- lapply(vids, function(x) distances(ng, x, refvid))
  dist <- round(as.numeric(as.matrix(dist_raw))/1000)
  df <- data.frame(n_post_nodes, "distance" = as.matrix(dist))
  #Range of inputs to create x-axis, taken from maximum distance of non-MVP2 inputs
  range <- c(1:150)
  #Creates points to plot on x-axis
  freq.mat <- as.matrix(lapply(range, function(x) sum(df$distance == x)))
  freq.df <- data.frame("freq" = as.numeric(freq.mat), "distance" = range)
  # norm <- function(x) {
  #  return ((x - min(x)) / (max(x) - min(x))) }
  #final_df <- as.data.frame(lapply(freq.df, norm))
  freq.df[freq.df$freq == 0,] <- NA
  return(freq.df)
}

M6.MVP2R <- synapse_distance(2109445, 2333007)
M6.MVP2L <- synapse_distance(2109445, 2120177)
M4.MVP2R <- synapse_distance(4291899, 2333007)
M4.MVP2L <- synapse_distance(4291899, 2120177)
M6L.MVP2L <- synapse_distance(2699293, 2120177)

anti.M6.MVP2R <- anti_synapse_distance(2109445, 2333007)
anti.M6.MVP2L <- anti_synapse_distance(2109445, 2120177)
anti.M4.MVP2R <- anti_synapse_distance(4291899, 2333007)
anti.M4.MVP2L <- anti_synapse_distance(4291899, 2120177)
anti.M6L.MVP2L <- anti_synapse_distance(2699293, 2120177)


# scatterplot
#M6
plot(anti.M6.MVP2R$freq, xlab = "Distance from spike initiation zone (μm)", 
     ylab = "Number of synapses", col = "gray80", ylim = c(0, 60), type = "p", pch=16,cex=1, xlim = c(0, 150))
par(new = T)
plot(anti.M6.MVP2L$freq,  col = "gray80" ,  ylim = c(0, 60), type = "p", pch=16,cex=1, xlab = "", ylab = "" , xlim = c(0, 150))
par(new = T)
plot(anti.M6L.MVP2L$freq,  col = "gray1" , ylim = c(0, 60), type = "p", pch=16,cex=1, xlab = "", ylab = "", xlim = c(0, 150))
par(new = T)
plot(M6.MVP2R$freq,  col = "firebrick1", ylim = c(0, 60), type = "p", pch=16,cex=1, xlab = "", ylab = "", xlim = c(0, 150))
par(new = T)
plot(M6.MVP2L$freq,  col = "firebrick1" ,  ylim = c(0, 60), type = "p", pch=16,cex=1, xlab = "", ylab = "", xlim = c(0, 150))
par(new = T)
plot(M6L.MVP2L$freq, col = "darkorchid1" ,  ylim = c(0, 60), type = "p", pch=16,cex=1, xlab = "", ylab = "", xlim = c(0, 150))
legend(95, 60, legend = c("Non-MVP2 Inputs to M6", "Non-MVP2 Inputs to M6L", "MVP2 > M6", "MVP2 > M6L"), fill = c("gray80", "gray1", "firebrick1", "darkorchid1"), cex = 1)


#M4
plot(anti.M4.MVP2R$freq,  col = "gray40" , ylim = c(0, 150), xlim = c(0, 100), type = "p", pch=16,cex=1, xlab = "Distance from spike initiation zone (μm)", ylab = "Number of synapses")
par(new = T)
plot(anti.M4.MVP2L$freq, col = "gray40" ,  ylim = c(0, 150), type = "p", pch=16,cex=1, xlab = "", ylab = "", xlim = c(0, 100))
par(new = T)
plot(M4.MVP2R$freq,  col = "deepskyblue" ,  ylim = c(0, 150), type = "p", pch=16,cex=1, xlab = "", ylab = "", xlim = c(0, 100))
par(new = T)
plot(M4.MVP2L$freq,  col = "deepskyblue" ,  ylim = c(0, 150),type = "p", pch=16,cex=1, xlab = "", ylab = "", xlim = c(0, 100))
legend(65, 145, legend = c("Non-MVP2 Inputs to M4", "MVP2 > M4"), fill = c("gray40", "deepskyblue", cex = 1))


