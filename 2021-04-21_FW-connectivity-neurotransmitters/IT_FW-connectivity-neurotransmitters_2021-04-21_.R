### UNDER CONSTRUCTION ###


# plot neurons in the hl, the neurons should be in different colours of your choice
# optional: create a ngl scene
# Intermediate:
#   find which neurotransmitter is expressed in each cell
# plot neurons in the hl, the neurons should be colour coded according to their neurotransmitters 
# [example; all neurons expressing GABA plotted in blue, serotonin expressing neurons in yellow etc]
# Advanced:
#   get downstream connectivity for each neuron
# Plot the proportion of downstream targets that are GABA, Glut, etc. (recommended plot: boxplot)
# Plot number of weak and strong partners (where weak corresponds to <1% of target’s synapses accounted for by an upstream partner and strong is >= 1%) in axon and dendrites separately
# The exercise should be done considering the RHS only.

# libraries
library(RColorBrewer)
library(hemibrainr)
library(googlesheets4)
library(tidyverse)
library(magrittr)
library(fafbseg)

# I can't access it
source("R/FAFB/flywire_meta.R")

# 
hl<- flywire_tracing_sheets(".*LHp2_lateral_right")  # specific  hl
# getting the fwlatest id because I can't read from the sheet
hl$flywire.id <- flywire_xyz2id(hl$flywire.xyz, rawcoords = TRUE)
# filter 
hl %<>% 
  filter(status == 'complete'| status == 'adequate') 
c('complete', 'adequate')

# predictions
hl_ntpred <- flywire_ntpred(hl$flywire.id)

# main nt in hl
hl_ntpred %>%
  group_by(pre_id, top.nt) %>%
  summarise(sum = n()) %>%
  filter(sum == max(sum))  -> hl_ntmax  #  acetylcholine  6737
# use table() instead of groupy_by and summarise
# downloading mesh
hl_mesh <- read_cloudvolume_meshes(hl$flywire.id)
# plot
color <-display.brewer.pal(8,"GnBu")
clear3d()
plot3d(hl_mesh, col = color) # the color doesn't come up

# ngl scene
fw_sc=ngl_decode_scene('https://ngl.flywire.ai/?json_url=https://globalv1.flywire-daf.com/nglstate/5948907318149120')
# and convert to URL
u2 =as.character(fw_sc+hl$flywire.id)
# to open the url in the browser
browseURL(u2)




# nt in each cell
hl_ntpred %>%
  group_by(pre_id, top.nt) %>%
  summarise(sum = n()) %>% # I did the following because the hl_ntpred df has a prediction per synapse and not per neuron
  top_n(1) -> n_ntpred

hl_ntpred %>%
  group_by(pre_id, top.nt) %>%
  summarise(sum = n()) -> test

# for loop if a nt then a specific color
nt_col <- data.frame(nt = unique(hl_ntpred$top.nt),
                 color = c('red', 'blue', 'yellow', 'green', 'black', 'purple'))

# creates a column 'color' and assingns it the relevant color according to nt
n_ntpred$color <- nt_col$color[match(n_ntpred$top.nt, nt_col$nt)]

n_ntpred_mesh <- read_cloudvolume_meshes(n_ntpred$pre_id) # not essential because I already read the mesh
  
clear3d()
plot3d(n_ntpred_mesh, col = n_ntpred$color) 





# downstream predictions, the hl_ntpred df has the post_id INTERRUPTED taking too long
ds_ntpred <- flywire_ntpred(unique(hl_ntpred$post_id))

# axon, dendrite
# All flywire IDs for neurons that have a split precomputed
#source("~/Documents/GithubRepositories/adulttracts/R/FAFB/flywire_meta.R")
fw.ids = flywire_ids()
fw.meta = flywire_meta(local=FALSE, folder = "flywire_neurons/")
