#Attempt to make a mesh 

library(catnat)

#Read neuron that you want to make a mesh from
neuron = read.neuron.catmaid(2333007)
#Split the neuron from a distal point, this distal fragment will be what your mesh is made from
index = match(2883647, neuron$d$PointNo)#add error handling
neuron.distal = elmr::distal_to(neuron, index)
neuron.distal.points = neuron$d[neuron.distal,]



pedc=distal_to(neuron, node.pointno = 2883647)
subset_pedc = subset(neuron, pedc)


pedc3=distal_to(neuron, node.pointno = 2883647)
subset_pedc3 = subset(neuron, pedc3)

nopen3d()
plot3d(neuron)


# Fetch a finished DL1 projection neuron
finished_pns=catmaid_get_neuronnames('annotation:^LH_DONE')
# should only be one neuron but pick first just in case
dl1skid=names(grep('DL1', finished_pns, value = T))[1]
dl1=read.neuron.catmaid(dl1skid)
# subset to part of neuron distal to a tag "SCHLEGEL_LH"
dl1.lh=subset(dl1, distal_to(dl1,node.pointno = dl1$tags$SCHLEGEL_LH))
plot(dl1,col='blue', WithNodes = F)
plot(dl1.lh, col='red', WithNodes = F, add=T)
plot3d(dl1.lh)

subset_pedc2 = subset(neuron, pedc)
n.pedc=subset(neuron, distal_to(neuron,node.pointno = 2883647))
plot(neuron,col='blue', WithNodes = F)
plot(n.pedc, col='red', WithNodes = F, add=T)
plot3d(subset_pedc)
plot3d(n.pedc)
plot3d(subset_pedc2)
plot3d(subset_pedc3)
?subset



copying_connectors = copy_tags_connectors(n.pedc, neuron, update_node_ids = FALSE)














#Make an alpha shape from the fragment using Alex's function
#cluster group size = 100 
# max distance between points = 10000
# alpha = 3000
pedc_ashape_2 <- make.anatomical.model(copying_connectors)
pedc_mesh3d_2 <- ashape2mesh3d(pedc_ashape_2)



?neurites.inside
?make.anatomical.model
library(catnat)
make.anatomical.model(neuron)


#Plot mesh and neuron
plot3d(pedc_mesh3d_2, xlab = "", ylab = "", zlab = "", box = FALSE, axes = FALSE, alpha = 0.3, col = "darkolivegreen4")
plot3d(neuron, col = "gray47")

#Plot connectors
connectors <- neuron$connectors
connectors.outgoing = connectors[connectors$prepost == 0,]
connectors.incoming = connectors[connectors$prepost == 1,]
points3d(connectors.outgoing[,c('x','y','z')], col = "Red", size = 3, alpha = 0.2)
points3d(connectors.incoming[,c('x','y','z')], col ="Cyan", size = 3, alpha = 0.2)

#Useful functions
pop3d()
#clear3d()
#nopen3d()


















#Now try to look at connections within that neuropil
neurons.inside
pointsinsidemesh

#Get a neuronlist to search (all neurons connected to neuron of interest)
neurons = read.neurons.catmaid(2333007)
connected_neurons = get_connected_skeletons(neurons)

#Get a list of all neurons in pedc
neurons_in_pedc_2 = neurons.inside(pedc_ashape_2, connected_neurons)
names(neurons_in_pedc_2)

#Extract skids
extract_skids <- function(a.neuron.list){
                 fun = a.neuron.list[[x]]$skid
                 lapply(x, fun)
}

extract_skids(neurons_in_pedc)

length(neurons_in_pedc)
skids1 = neurons_in_pedc[[1]]$skid
skids2 = neurons_in_pedc[[14]]$skid

xyz = c(connectors$x, connectors$y, connectors$z)
pointsinsidemesh(connectors.incoming, pedc_mesh3d_2, rval = "logical")



##FINAL ANSWWER
logical = pointsinsidemesh(connectors.incoming, pedc_mesh3d_2, rval = "logical")
nrow(connectors.incoming)
length(logical)
indices = which(logical)
incoming.mesh = connectors.incoming[indices,]
incoming.mesh.conid = incoming.mesh$connector_id
pre.skid.df = catmaid_get_connectors(incoming.mesh.conid)
pre.skids.inside.with.duplicates = pre.skid.df$pre
pre.skids.inside.mesh = unique(pre.skids.inside.with.duplicates)
length(pre.skids.inside.mesh)
#omit skids with nodes less than a certain value??
#How do I read all of these skids to get a db of neurons? Or is this too big? read.neurons.catmaid doesnt seem to work.


