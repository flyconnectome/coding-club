#vector of probabilities associated with each confidence value
confidence_probs <- c(1,0.9,0.7,0.4,0.3)
names(confidence_probs) <- c(5,4,3,2,1)

#Calculates a 'total confidence' for every node in the neuron's treenode table. Confidences are calculated with respect to the soma as the root.
#e.g. a total confidence of 0.2 indicates a 20% chance that the node is actually connected to the soma
#Confidences are calculated by walking from the root to the node and cumulatively multiplying the edge confidences encountered on the way
#e.g. passing through a 3 (0.4 confidence), then another three (0.4*0.4 = 0.16 confidence)

#Inputs are the 'skid' of the neuron of interest and 'confidence_probs', a named vector as above. Specifies the probabilities attached to each
#confidence value 1-5 e.g. a value of 0.4 for 3, implies a 40% likelihood the connection is correct.

#Horribly ineffiecient looping BFS (need to modify this to make it more efficient)
confidence_nodes <- function(skid,confidence_probs) {
    #read neuron
    neuron <- read.neuron.catmaid(skid)
    #Gets treenode table of neuron
    nodes <- catmaid_get_treenode_table(skid)
    
    #Gets id of root node and checks if this is the soma - will stop if not
    root <- nodes$id[is.na(nodes$parent_id)]
    if (root != neuron$tags$soma) {
        stop('The root is not the soma! Go and re-root')
    }
    
    #sets up total confidence column with root confidence of 1
    nodes$total_conf <- rep(0,length(nodes$id))
    nodes$total_conf[nodes$id == root] <- 1
    #change the parent of the root to be the string NA to stop the NA value intefering with calculations
    nodes$parent_id[nodes$id == root] <- 'NA'
    #sets current node to child of the root (add something in to make it fail if multiple
    #children)
    current_id <- nodes$id[nodes$parent_id == root]
    #print(paste('id',as.character(current_id)))
    
    #list of nodes to check
    to_check <- list(current_id)
    #Counter for iterations (just to check it's working)
    counter <- 0
    #loops through nodes in a BFS manner
    while(length(to_check ) > 0) {
        counter <- counter + 1
        #print(counter)
        current_id <- to_check[[1]]
        to_check[1] <- NULL
        #sets total confidence as that of parent node * edge confidence weight
        nodes$total_conf[nodes$id == current_id] <- 
            nodes$total_conf[nodes$id == nodes$parent_id[nodes$id == current_id]]*confidence_probs[as.character(nodes$confidence[nodes$id == current_id])]
        to_check <- c(to_check,nodes$id[nodes$parent_id == current_id])
    }
    return(nodes)
    }

#calculates total confidence of synaptic connections - 'skid' is the neuron of interest, 'node_conf' is the output table from the node function,
#'confidence_probs' is the vector of probabilities assigned to each confidence value (as above)

#Synapse confidences are calculated as the confidence of the tree-node * synapse pre confidence * synapse post confidence
#This measure is probably a bit harsh, especially for pre and post - could do with easing it off a bit.
confidence_connectors <- function (skid,node_conf,confidence_probs) {
    #get up and downstream connectors
    connectors_down <-catmaid_get_connectors_between(pre_skid = skid)
    connectors_up<-catmaid_get_connectors_between(post_skid = skid)
    
    #Get corresponding tree-node confidences for upstream and downstream synapses
    tree_conf_down <- sapply(connectors_down$pre_node_id, function (x) {node_conf$total_conf[node_conf$id == x]})
    tree_conf_up <- sapply(connectors_up$post_node_id, function(x) {node_conf$total_conf[node_conf$id == x]})
    #Calculate total confidence of synapse by multiplying tree-node confidence with that of synapse edges
    connectors_down$total_conf <- (tree_conf_down*confidence_probs[as.character(connectors_down$pre_confidence)]*confidence_probs[as.character(connectors_down$post_confidence)])
    connectors_up$total_conf <- (tree_conf_up*confidence_probs[as.character(connectors_up$pre_confidence)]*confidence_probs[as.character(connectors_up$post_confidence)])
    
    #merge the up and downstream data frame together for return.
    return(merge(connectors_down,connectors_up,all=T))
}

#Adjust connectivity totals based on total synapse confidence - 
#'skid' is the neuron of interest, syn_conf' is the output from the synapse function above,
#method of adjustment, either 'normalised' or 'cutoff' - normalised will give the conenctivity as the sum of the confidences of each individual
#synapse e.g. a synaptic connection of confidence 0.3 will count as 0.3 of a synapse in the connectivity stats
#cutoff will discard synapses below the provided confidence value and return the number of synapses remaining (doesn't adjust the rest
#for their confidence)
#'cut off' is a confidence at, and below which, synapses should be discarded e.g. 0.2
connectivity_adjust <- function(skid,syn_conf,method,cut_off = 1) {
    #get all connected skids, removing the seed skid
    connected_skids <- unique(c(syn_conf$pre_skid,syn_conf$post_skid))
    connected_skids <- connected_skids[connected_skids != skid]
    
    #just upstream
    upstream <- syn_conf[syn_conf$post_skid == skid,]
    #just downstream
    downstream <- syn_conf[syn_conf$pre_skid == skid,]
    #create summary data frame for total vs adjusted synapses
    sum_up <- data.frame(connected_skids)
    #calculate total synapses + upstream vs downstream
    sum_up$total <- sapply(connected_skids, function (x) {sum(syn_conf$pre_skid == x | syn_conf$post_skid==x)})
    sum_up$upstream <- sapply(connected_skids, function(x) {sum(upstream$pre_skid == x)})
    sum_up$downstream <- sapply(connected_skids, function(x) {sum(downstream$post_skid == x)})
    #for normalised adjusted number is just sum of the individual synapse confidences
    if (method == 'normalised') {
        sum_up$adjusted_total <- sapply(connected_skids, function(x) {sum(syn_conf$total_conf[syn_conf$pre_skid == x | syn_conf$post_skid == x])})
        sum_up$adjusted_up <- sapply(connected_skids, function(x) {sum(upstream$total_conf[upstream$pre_skid ==x])})
        sum_up$adjusted_down <- sapply(connected_skids, function(x) {sum(downstream$total_conf[downstream$post_skid ==x])})
    #for cutoff, adjusted number is the total above the provided confidence cutoff
    } else if (method == 'cut off') {
        cut_syns <- syn_conf[syn_conf$total_conf > cut_off,]
        cut_up <- upstream[upstream$total_conf > cut_off,]
        cut_down <- downstream[downstream$total_conf > cut_off,]
        sum_up$adjusted_total <- sapply(connected_skids, function (x) {sum(cut_syns$pre_skid == x | cut_syns$post_skid == x)})
        sum_up$adjusted_up <- sapply(connected_skids, function(x) {sum(cut_up$pre_skid == x)})
        sum_up$adjusted_down <- sapply(connected_skids, function(x) {sum(cut_down$post_skid == x)})
    #stop if any other value is supplied
    } else {
        stop('entered method is incorrect')
    }
    return(sum_up)
}

#wrapper to calculate node and synapse confidences and then plot this on the neuron as
#a sliding scale from blue (low confidence) to red (high confidence)
#enter 'skid' and 'confidence_probs' - list of 5 probabilities corresponding to the 
#confidence values in CATMAID e.g. c(1,0.9,0.7,0.4,0.3) indicates a 5 is 100% confident,
#a 4 is 90%, a 3 is 70% and so on...
#can specify a certain skid 'selected' = skid so that only synapses to that neuron
#will be plotted (mark location by black spot also to make them more visible)
#, otherwise shows them all
plot_confidence <- function(skid,confidence_probs=c(1,0.9,0.7,0.4,0.3),selected=NA) {
    #name the vector of confidences
    names(confidence_probs) <- c(5,4,3,2,1)
    node_conf <- confidence_nodes(skid,confidence_probs)
    syn_conf <- confidence_connectors(skid,node_conf,confidence_probs)
    
    #make a colour palette to ramp from blue to red
    coloursy <- colorRampPalette(c('blue','red'))
    #multiple confidences by 100 and round to nearest integer
    select <-round(node_conf$total_conf*100)
    #set all 0 values to 1 [palette of colours is 1 to 100, so 0 should default to 1]
    select[select == 0] <-1
    #add a colour column to the node table
    node_conf$colour<- coloursy(100) [as.numeric(select)]
    
    #Same as above for the synapse table
    select <-round(syn_conf$total_conf*100)
    select[select == 0] <-1
    syn_conf$colour<- coloursy(100) [as.numeric(select)]
    
    #if a neuron is 'selected' plots synapses for it alone + for nodes of skeleton
    if (!is.na(selected)) {
        nopen3d()
        plot3d(FAFB, alpha=0.1)
        points3d(node_conf[,c('x','y','z')], col=node_conf$colour)
        just_selected <- syn_conf[syn_conf$pre_skid == selected | syn_conf$post_skid == selected,]
        points3d(just_selected[,c('connector_x','connector_y','connector_z')],col='black',size=10)
        text3d(just_selected[,c('connector_x','connector_y','connector_z')], col=just_selected$colour, text='*', cex=5)
    #otherwise plots node confidences + all synapses
    } else {
        nopen3d()
        plot3d(FAFB, alpha=0.1)
        points3d(node_conf[,c('x','y','z')], col=node_conf$colour)
        text3d(syn_conf[,c('connector_x','connector_y','connector_z')], col=syn_conf$colour, text='*', cex=3)
    }
    
}

#wrapper to get adjusted confidence connectivity table for a particular skid. Confidence_probs as for all functions above, method/cut_off 
#as in the connectivty_adjust function
adjust_confidence <- function(skid,confidence_probs=c(1,0.9,0.7,0.4,0.3),method,cut_off=1) {
    #name the vector of confidences
    names(confidence_probs) <- c(5,4,3,2,1)
    #Get node and synapse confidence
    node_conf <- confidence_nodes(skid,confidence_probs)
    syn_conf <- confidence_connectors(skid,node_conf,confidence_probs)
    #get adjusted connectivity table
    new_connectivity <- connectivity_adjust(skid,syn_conf,method,cut_off)
    return(new_connectivity)
}
