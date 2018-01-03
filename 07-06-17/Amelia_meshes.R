load("~/projects/mesh_y1_pedc.RData")

#Read neuron that you want to make a mesh from
neuron = read.neuron.catmaid(2333007)
pedc=distal_to(neuron, node.pointno = 2883647)
subset_pedc = subset(neuron, pedc)

#Make an alpha shape from the fragment using Alex's function :)
#cluster group size = 100 
# max distance between points = 10000
# alpha = 10000 
#NB the higher the alpha value the smoother and looser the mesh
pedc_ashape <- make.anatomical.model(subset_pedc, substrate = "cable") #Function does not work for substrate = "connectors" or "both"

##########################################################################################################################################
pedc_mesh3d <- ashape2mesh3d(pedc_ashape)


#Plot mesh and neuron
nopen3d()
plot3d(pedc_mesh3d, xlab = "", ylab = "", zlab = "", box = FALSE, axes = FALSE, alpha = 0.3, col = "darkolivegreen4")
plot3d(neuron, col = "gray47")

#Plot connectors
connectors <- neuron$connectors
connectors.outgoing = connectors[connectors$prepost == 0,]
connectors.incoming = connectors[connectors$prepost == 1,]
points3d(connectors.outgoing[,c('x','y','z')], col = "Red", size = 3, alpha = 0.2)
points3d(connectors.incoming[,c('x','y','z')], col ="Cyan", size = 3, alpha = 0.2)


#Now try and see what's going on inside the mesh you've made
#This gets a list of all the skids that input onto your neuron inside your mesh

logical.incoming = pointsinsidemesh(connectors.incoming, pedc_mesh3d, rval = "logical")
nrow(connectors.incoming)
length(logical.incoming) # Check both are the same length
indices.incoming = which(logical.incoming) #Gives indices of TRUE value
incoming.mesh = connectors.incoming[indices.incoming,] #Subset incoming connectors for values inside of mesh (by matching where TRUE occured)
incoming.mesh.conid = incoming.mesh$connector_id #Subset to get connector_id
pre.skid.df = catmaid_get_connectors(incoming.mesh.conid) #Get a df of skids connected to these connector_ids
pre.skids.inside.with.duplicates = pre.skid.df$pre #Subset to only get list of pre skids
pre.skids.inside.mesh = unique(pre.skids.inside.with.duplicates) #Remove duplicate skids

#Now we have a list of skids that we know connect to our neuron of interest inside our mesh
length(pre.skids.inside.mesh)  #Tells us how many in total 
#omit skids with nodes less than a certain value??
#How do I read all of these skids to get a db of neurons? Or is this too big? read.neurons.catmaid doesnt seem to work.
#What else can we do to analyse what's going on inside our mesh?
#Once calculated the outgoing below is it possible to use match() function to see if there are neurons that are both pre and postsynaptic?

#Also do the same for outgoing:
logical.outgoing = pointsinsidemesh(connectors.outgoing, pedc_mesh3d, rval = "logical")
nrow(connectors.outgoing)
length(logical.outgoing) # Check both are the same length
indices.outgoing = which(logical.outgoing) #Gives indices of TRUE value
outgoing.mesh = connectors.outgoing[indices.outgoing,] #Subset outgoing connectors for values inside of mesh (by matching where TRUE occured)
outgoing.mesh.conid = outgoing.mesh$connector_id #Subset to get connector_id
post.skid.df = catmaid_get_connectors(outgoing.mesh.conid) #Get a df of skids connected to these connector_ids
post.skids.inside.with.duplicates = post.skid.df$post #Subset to only get list of pre skids
post.skids.inside.mesh = unique(post.skids.inside.with.duplicates) #Remove duplicate skids
length(post.skids.inside.mesh)

##########################################################################################################################################
#Make a mesh for y1, excluding pedc
#Make an alpha shape from the original neuron using Alex's function :)
#cluster group size = 100 
# max distance between points = 10000
# alpha = 10000 
#NB the higher the alpha value the smoother and looser the mesh
y1_ashape <- make.anatomical.model(neuron, substrate = "cable") #Function does not work for substrate = "connectors" or "both"

##########################################################################################################################################
y1_mesh3d <- ashape2mesh3d(y1_ashape)


#Plot mesh and neuron
nopen3d()
plot3d(pedc_mesh3d, xlab = "", ylab = "", zlab = "", box = FALSE, axes = FALSE, alpha = 0.3, col = "darkolivegreen4")
plot3d(y1_mesh3d, xlab = "", ylab = "", zlab = "", box = FALSE, axes = FALSE, alpha = 0.3, col = "darkorchid")
plot3d(neuron, col = "gray47")
#For some reason cannot plot both meshes on the same graph with neuron on top


#Plot connectors
connectors <- neuron$connectors
connectors.outgoing = connectors[connectors$prepost == 0,]
connectors.incoming = connectors[connectors$prepost == 1,]
points3d(connectors.outgoing[,c('x','y','z')], col = "Red", size = 3, alpha = 0.2)
points3d(connectors.incoming[,c('x','y','z')], col ="Cyan", size = 3, alpha = 0.2)
