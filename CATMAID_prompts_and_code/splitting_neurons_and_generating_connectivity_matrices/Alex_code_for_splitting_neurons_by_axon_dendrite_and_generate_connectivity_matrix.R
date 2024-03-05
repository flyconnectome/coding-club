#install.packages(install_github("alexanderbates/catnat"))
library(catnat)
# Fetch neurons
opns.em = read.neurons.catmaid("annotation:WTPN2017_AL_PN")
lhns.done = read.neurons.catmaid("annotation:WTPN2017_LHNs")
lhns.done.flow = catnat::flow.centrality(lhns.done, polypre= FALSE, mode = "centrifugal", split = "distance")

lhregion = subset(FAFB14NP.surf,"LH_R")
lhbigger <- Morpho::rotonto(xyzmatrix(lhregion),xyzmatrix(lhregion*1.25),reflection=F,scale=F)
xyzmatrix(lhregion) <- xyzmatrix(Morpho::applyTransform(x=xyzmatrix(lhregion*1.25),trafo = Morpho::getTrafo4x4(lhbigger)))

# Split and collate compartments
lhns.done.flow.dendrites = nlapply(lhns.done.flow,dendritic_cable)
lhns.done.flow.axons = nlapply(lhns.done.flow,catnat:::axonic_cable.catmaidneuron)
names(lhns.done.flow.dendrites) = paste0(lhns.done.flow.dendrites[,"cell"],"_dendrites")
names(lhns.done.flow.axons) = paste0(lhns.done.flow.axons[,"cell"],"_axon")
lhns.done.flow.axons[,"compartment"] = "axon" 
lhns.done.flow.dendrites[,"compartment"] = "dendrite"
lhn.bits= c(lhns.done.flow.dendrites,lhns.done.flow.axons)

## If the neurons are not well trace,d you can split in other ways, inc. by neuropil compartment, e.g. 
opns.em.lh.termini = nlapply(opns.em, catnat:::prune_in_volume, brain = lhregion, neuropil = NULL,OmitFailures = TRUE)

# Get connectivity matrix
lhns.scm = catnat::skeleton_connectivity_matrix(pre=opns.em.lh.termini,post=lhns.done.flow.dendrites)


aspg.skid <- 534333

?dendritic_cable.catmaidneuron

dendritic_cable(lhns.done[[1]])
library(catnat)
?dendritic_cable
