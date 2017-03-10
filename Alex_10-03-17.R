devtools::install_github("alexanderbates/catnat")
?synapsecolours.neuron

# Example
amadan = read.neuron.catmaid("name:Amadan") # Interesting LHON
synapsecolours.neuron(amadan,skids = c("346114","1420974","2152181"),printout=T) 

# See the guts of the function
synapsecolours.neuron

# function (neuron, skids = NULL, col = "black", inputs = T, outputs = T, 
#           printout = F) 
# {
#   if (is.neuronlist(neuron)) {
#     neuron = neuron[[1]]
#   }
#   plot3d(neuron, WithNodes = F, soma = T, col = col, lwd = 2)
#   plot.new()
#   if (inputs) 
#     inputs = neuron$connectors[neuron$connectors$prepost == 
#                                  1, ]
#   c = subset(catmaid_get_connectors(inputs$connector_id), post == 
#                neuron$skid)[, -3]
#   inputs = merge(inputs, c, all.x = F, all.y = F)
#   if (!is.null(skids)) {
#     inputs = subset(inputs, pre %in% skids)
#   }
#   colours = data.frame(pre = unique(inputs$pre), col = rainbow(length(unique(inputs$pre))))
#   inputs = merge(inputs, colours, all.x = T, all.y = F)
#   if (nrow(inputs) > 0) {
#     points3d(nat::xyzmatrix(inputs), col = inputs$col)
#     if (printout) 
#       legend("left", legend = catmaid_get_neuronnames(colours$pre), 
#              fill = colours$col, cex = 2/nrow(colours))
#   }
#   if (outputs) 
#     outputs = neuron$connectors[neuron$connectors$prepost == 
#                                   0, ]
#   c = subset(catmaid_get_connectors(outputs$connector_id), 
#              pre == neuron$skid)[, -2]
#   outputs = merge(outputs, c, all.x = F, all.y = F)
#   if (!is.null(skids)) {
#     outputs = subset(outputs, post %in% skids)
#   }
#   colours = data.frame(post = unique(outputs$post), col = rainbow(length(unique(outputs$post))))
#   outputs = merge(outputs, colours, all.x = T, all.y = F)
#   if (nrow(outputs) > 0) {
#     text3d(nat::xyzmatrix(outputs), text = "*", col = outputs$col, 
#            cex = 2)
#     if (printout) 
#       legend("right", legend = catmaid_get_neuronnames(colours$post), 
#              col = colours$col, cex = 2/nrow(colours))
#   }
# }
