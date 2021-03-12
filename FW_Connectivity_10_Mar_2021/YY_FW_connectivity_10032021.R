# This script intends to: 
# Find downstream partners of 720575940603560294 (LHa1 hemilineage)
# Get the neuron's top five partners based on the number of synapses
# Plot the neuron and each partner (include the synapses in the plot) for all five neurons, and have the synapses colour coded by partner
# Advance task
# Construct a neuroglancer scene with the neuron of interest and its top five partners (note: the top five partners should be the same color as it's relevant synapse colour assigned in point 3)
# NBLAST connectivity matrix of the LHa1 hemilineage [thresholds 1. include adequate/complete neurons 2. include connections with more than 5 synapses per neuron]
library(natverse)
library(fafbseg)
library(googlesheets4)
library(ggplot2)
library(hemibrainr)
library(ComplexHeatmap)
library(tidyverse)

# Plot top 5 downstream partners ####
id <- flywire_latestid('720575940603560294')

# get top 5 downstream ids 
n.downstream <- flywire_partner_summary(id, method = 'spine')
top5.ids <- n.downstream$post_id[1:5]

# get meshes for plotting 
n <- read_cloudvolume_meshes(id)
top5 <- read_cloudvolume_meshes(top5.ids)
neuron_colour <- data.frame(
  ids = top5.ids, 
  colours = c('red','green','blue','yellow','pink')
)

# get synapses 
syn <- flywire_ntpred(id)
# syn$post_id is originally double, making it hard to be compared with the ones we have 
syn$post_id <- as.character(syn$post_id)
syn1 <- syn[syn$post_id %in% top5.ids,]

# add colours to the df, matching the ids 
syn1 <- merge(syn1, neuron_colour, by.x = 'post_id', by.y = 'ids', all.x = T)
flywire_ntplot3d(syn1, col = syn1$colours)

# Plot! 
plot3d(n, add = T, col = 'brown', alpha = 0.5)
plot3d(top5, add = TRUE, col = neuron_colour$colours, alpha = 0.2)
points3d(syn1$pre_x, syn1$pre_y, syn1$pre_z, col = syn1$colours)


# Flywire URL#### 
# get sample FlyWire URL
fw_url=with_segmentation('flywire', getOption('fafbseg.sampleurl'))
fw_sc=ngl_decode_scene(fw_url)
url <- as.character(fw_sc + c(id,top5.ids) - 0)
url.colors <- as.character(ngl_add_colours(url, data.frame(
  ids <- c(id, top5.ids), 
  col <- c('brown',neuron_colour$colours)
)))
# This line opens the url: 
browseURL(url.colors)


# Adjancency matrix and NBLAST ####
LHa1.he <- read_sheet('1QyuHFdqz705OSxXNynD9moIsLvZGjjBjylx5sGZP2Yg', sheet = 'ItoLee_Hemilineage_LHa1_right')
# You need to make sure they are unique, otherwise flywire_partner_summary() finds it twice 
LHa1.ac.ids <- unique(flywire_xyz2id(LHa1.he$flywire.xyz[LHa1.he$status %in% c('adequate', 'complete', 'a', 'c')], rawcoords = T)) 

# get connectivity between these neurons 
LHa1.in <- flywire_partner_summary(LHa1.ac.ids, partners = 'inputs', method = 'spine')
LHa1.in5.lha1 <- LHa1.in[LHa1.in$weight > 5 & LHa1.in$pre_id %in% LHa1.ac.ids,]

# This if for ggplot, in the format of: 
# pre post weight
# 1   2     0
# 1   3     1
# 1   4     0
# 2   1     0
# 2   2     0
# ...
conn <- expand.grid(pre_ids = LHa1.ac.ids, post_ids = LHa1.ac.ids)
conn <- merge(conn, LHa1.in5.lha1, 
              by.x = c('pre_ids', 'post_ids'), by.y = c('pre_id', 'query'), 
              all.x = T)
conn$weight[is.na(conn$weight)] <- 0

# morphological clustering
# skeletonise yourself - can you get skeletons from google drive? 
read_cloudvolume_meshes(LHa1.ac.ids, savedir = '/Users/yijieyin/Downloads/LHa1')
ff = file.path('/Users/yijieyin/Downloads/LHa1', paste0(LHa1.ac.ids,'.obj'))
# This downloads the mesh again anyway, despite the downloading above 
# If it gives you failures with some ids, just try again 
LHa1.sk <- skeletor(ff)
LHa1.dps <- dotprops(LHa1.sk/1000, k = 5, resample = 1)
LHa1.scores <- nblast_allbyall(LHa1.dps)
LHa1.hc <- nhclust(scoremat = LHa1.scores)

# plot! 
# This ggplot doesn't give a dendrogram properly 
hm <- ggplot(data = conn, mapping = aes(x = pre_ids, 
                                        y = post_ids, 
                                        fill = weight)) + 
  geom_tile() + 
  geom_text(aes(label = weight)) + 
  scale_fill_gradient(low = 'white', high = 'red') + 
  theme(axis.text.x = element_blank(), 
        axis.text.y = element_blank())
hm

# This gives the clustering you want 
mtx <- pivot_wider(conn[,1:3], names_from = post_ids, values_from = weight)
mtx1 <- mtx[,-1]
rownames(mtx1) <- mtx$pre_ids
Heatmap(data.matrix(mtx1), 
        name = 'Number of Synpases',
        show_row_names = FALSE, 
        show_column_names = FALSE, 
        cluster_rows = LHa1.hc, 
        cluster_columns = F)

