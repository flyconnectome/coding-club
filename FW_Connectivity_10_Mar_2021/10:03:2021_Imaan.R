
#load library
# go over library to see which one is essential!!
library(fafbseg)
library(natverse)
library(catmaid)
library(dplyr)
library(RColorBrewer)
library(googlesheets4)

# get the neuron rootid
rootid = flywire_rootid("720575940603560294", method='flywire')
# get the partners
partnersTopFive = head(flywire_partner_summary(rootid, partners = c("outputs")), 5)

# get the downstream partners
partnersv2 = flywire_partners(rootid, partners = c("outputs"), details=TRUE)

# This function plots the neuron of interest, partner and synapses
plotpartner_syn <- function(partner_id="", partnercolor="", syncolor="") {
  partnersv2 %>%
    # filter to get the relevant post_id
    filter(as.character(partnersv2$post_id)==partner_id) %>%
    # select the columns with the synapse xyz coords
    select(post_x, post_y, post_z) -> syn_xyz
  
  # plot
  noi = read_cloudvolume_meshes(rootid)
  partnerNeuron = read_cloudvolume_meshes(partner_id)
  clear3d()
  plot3d(noi, col="black")
  plot3d(partnerNeuron, col=partnercolor)
  points3d(syn_xyz, col=syncolor)
}

# using the function above I can plot the neuron of interest, partner and synapse

#create a for loop to go through partnersTopFive$post_id) and assign it a different color, use RColorBrewer
#for (i in partnersTopFive$post_id) {}

plotpartner_syn(partner_id = "720575940625576469", partnercolor='coral4', syncolor="coral")
plotpartner_syn(partner_id = "720575940620947848", partnercolor='brown4', syncolor="brown1")
plotpartner_syn(partner_id = "720575940625454418", partnercolor='blue4', syncolor="blue")
plotpartner_syn(partner_id = "720575940619738793", partnercolor='deeppink4', syncolor="deeppink")
plotpartner_syn(partner_id = "720575940506768403", partnercolor='darkolivegreen', syncolor="darkolivegreen1")

# ADVANCED #

# neuroglancer scene
blank = 'https://ngl.flywire.ai/?json_url=https://globalv1.flywire-daf.com/nglstate/5948907318149120'
sc=ngl_decode_scene(blank)
# and convert to URL
u2=as.character(sc+partnersTopFive$post_id+rootid)
# to open the url in the browser
browseURL(u2)

# adjacency matrix (heatmap) with nblast on the side for LHa1_right hemilineage. a/c and >5 synapses/neuron
# fetch a/c neurons of the LHa1_right hemilineage and get the root id
lab_sheet<-gs4_get('1QyuHFdqz705OSxXNynD9moIsLvZGjjBjylx5sGZP2Yg')
# find a better way to call the hemilineage i.e. by name
## add unique() next time!
lha1_right <- googlesheets4::read_sheet(lab_sheet, lab_sheet$sheets$name[85])
lha1_right%>%
  filter(lha1_right$status==c('complete', 'adequate')) -> lha1_right

# make coordinates 3*x data frame 
xyz <- xyzmatrix(lha1_right$flywire.xyz)
# get ids 
ids=flywire_xyz2id(xyz=xyz,rawcoords = T)

# flywire_adjacency_matrix()
adj_mat = flywire_adjacency_matrix(ids)
# filter adj_mat >5 synapses
adj_mat%>%
  filter()
#filter trial1
adj_mat[adj_mat[, 1] > 5, ]
#filter trial2
trial1 = subset(adj_mat, adj_mat[,4] >5)
# nblast the neurons and organise the heatmap by that
skeletons = skeletor(ids, brain = elmr::FAFB14.surf)

## suggested by greg
read_cloudvolume_meshes(ids, savedir='/some/path/')
ff=file.path('/some/path/', paste0(ids, '.obj'))
skeletor(ff) 









# plot neuron and each partner with synapses
# trial atatching snapses to neuron and I want to see whether
# I can subset it to the top 5 downstream partner

#skeletonise? WHY
neurons = skeletor(rootid, brain = elmr::FAFB14.surf)
neuronsSyn = flywire_neurons_add_synapses(neurons)
neuronsSyn <- neuronsSyn[["720575940603560294"]][["connectors"]]
# use marta trick to subset according to top five neurons
neuronsSyn %>%
  filter(as.character(neuronsSyn$post_id)==head(partners$post_id, 5)) -> filtered

 
# I want to plot the neuron with each partner and it's synapses
# plot neuron of interest, noi
noi = read_cloudvolume_meshes(rootid)
clear3d()
plot3d(noi, col="green")
synplt1= select(trial, post_x, post_y, post_z)
# trial, plot synapses
plot3d((noi), col= "blue1")
points3d(synplt1, col='')
display.brewer.pal(8, "Blues")
