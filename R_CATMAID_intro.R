#Introducing R/CATMAID
#http://jefferis.github.io/rcatmaid/

library(catmaid)

#Plot neuron
neuron <- read.neuron.catmaid(3673438)
neuronlist <- read.neurons.catmaid("annotation:NAMK_putative_PAM-y5_RIGHT$")

neuronlist[1]$`3025479`
neuronlist[[1]] #These two expressions are the same

nopen3d() #allows panning
plot3d(neuron, soma = TRUE, lwd = 2, alpha = 0.8, WithConnectors = TRUE, col = "black")
plot3d(FAFB14)
plot3d(FAFB14NP.surf, "CRE.R", col = "grey", alpha = 0.2) #alpha for different transparency
names(FAFB13NP.surf$Regions) #Names of regions that can be plotted

#Subset neuron
cut_point <- 21021349 #node id, can also use tag
index = match(cut_point, neuron$d$PointNo)
neuron.distal = distal_to(neuron, index)
neuron.distal.points = neuron$d[neuron.distal,]
#debug- graph to check selected distal points are in correct region
nopen3d()
plot3d(neuron, col = "gray23")
points3d(neuron.distal.points[,c('X','Y','Z')], col = "deepskyblue")

#NBLAST
library(elmr)
results=nblast_fafb(5917625, mirror = TRUE)
summary(results) 
plot3d(results, hits = 9, soma = TRUE)
fc_neuron("FruMARCM-M001152_seg001")

mal <- fc_neuron_type(regex = "aDT-b")
plot3dfc(names(mal), soma = TRUE)
n <- fetchn_fafb(1180353, mirror = FALSE)
plot3d(n, col = "black", soma = TRUE)
