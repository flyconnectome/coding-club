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

## Load lineage related data
source("R/startup/startup.R")
source("R/fafb/flywire_meta.R")

# subset fw.meta and filter a/c
# how to change a/c to adequate and complete or a faster
# way to filter it all
gs.survey %>%
  filter(ItoLee_Hemilineage == 'LHp2_lateral', side == 'right',
         status == 'adequate'| status == 'complete') -> hl
# update flywire id
hl_fwid <- flywire_latestid(hl$flywire.id)

# predictions
hl_ntpred <- flywire_ntpred(hl_fwid)

# main nt in hl
hl_ntpred$top.nt %>% 
  table() %>% 
  data.frame() %>% 
  top_n(1, Freq) -> hl_ntmax # acetylcholine 34299

# downloading mesh
hl_mesh <- read_cloudvolume_meshes(hl_fwid)

# plot
color <- brewer.pal(8,"Blues")
clear3d()
plot3d(hl_mesh, col = color) 

# ngl scene
fw_sc=ngl_decode_scene('https://ngl.flywire.ai/?json_url=https://globalv1.flywire-daf.com/nglstate/5948907318149120')

# assign the colors to the fw scene
# create a dataframe with a column of the id and another with the color
ngl_color <- data.frame(hl_fwid, color)
fw_sc <- ngl_add_colours(fw_sc+hl_fwid, ngl_color)

# to open the url in the browser
browseURL(as.character(fw_sc))




# nt in each cell
hl_ntpred %>%
  group_by(pre_id, top.nt) %>%
  dplyr::summarise(sum = n()) %>% # I did the following because the hl_ntpred df has a prediction per synapse and not per neuron
  top_n(1, sum) -> n_ntpred

# creates a column 'color' and assingns it the relevant color according to nt
n_ntpred$color <- paper.cols[match(n_ntpred$top.nt, names(paper.cols))]
  
clear3d()
plot3d(hl_mesh, col = n_ntpred$color) 


# get the downstream connectivity
hl_ds <- flywire_partner_summary(hl_fwid, partners = 'outputs')

# It will take too long to get the downstream prediciton
# through the flywire_ntpred() function, so I'm subseting it
# using gs.survey$transmitter

gs.survey %>%
  inner_join(hl_ds, by = c('flywire.id' = 'post_id')) %>%
  select(flywire.id, transmitter, weight) %>%
  filter(weight >= 5) %>%
  replace(is.na(.), 'unknown') %>%
  arrange(transmitter) -> hl_dsClean

# creates a column 'color' and assigns it the relevant color according to nt
hl_dsClean$color <- paper.cols[match(hl_dsClean$transmitter, names(paper.cols))]

color_ds <- unique(hl_dsClean$color)

ggplot(hl_dsClean) +
  aes(x = transmitter, y = weight) +
  geom_boxplot(shape = "circle", fill = color_ds) +
  scale_color_manual(values = color_ds) + ### THIS IS A PROBLEM, HOW TO COLOR THE LINES ###
  labs(x = "Transmitter of downstream neuron", y = "Weights") +
  theme_classic() +
  theme(legend.position = "none")
ggsave('~/Desktop/Plots/2021-04-21_hl-ds_boxplot.png', width= 10, dpi=600)


## MARTA's CODE ###

# There are duplicate flywire ids
table(duplicated(hl_dsClean$flywire.id))
# 
# FALSE  TRUE 
# 267   279 

# remove duplicated rows
# turn flywire to character
# turn NT to factor
# remove X column, added by the csv
hl_dsClean %<>%
  filter(!duplicated(flywire.id)) %>%
  mutate(flywire.id = as.character(flywire.id),
         transmitter = factor(transmitter)) %>%
  select(-X)

# df for cols
cols_df <- distinct(hl_dsClean, transmitter, color)
# making a named vector, with NT <> colour
cols_to_plot <- cols_df$color
names(cols_to_plot) <- cols_df$transmitter

# It's useful to plot the points
ggplot(hl_dsClean, aes(x = transmitter, y = weight, col = transmitter)) +
  geom_boxplot(shape = "circle") +
  geom_point(col = "grey80", alpha=0.5) +
  scale_color_manual(values = cols_to_plot) +
  labs(x = "Transmitter of downstream neuron", y = "Weights") +
  theme_classic() +
  theme(legend.position = "none")

ggsave('~/Desktop/Plots/2021-04-21_hl-ds_boxplot.png', width= 10, dpi=600)

ggplot(hl_dsClean, aes(x = transmitter, y = weight, col = transmitter)) +
  geom_boxplot(shape = "circle", outlier.shape = 5) +
  geom_point(col = "grey80", alpha=0.5) +
  scale_color_manual(values = cols_to_plot) +
  labs(x = "Transmitter of downstream neuron", y = "Weights") +
  theme_classic() +
  theme(legend.position = "none")

# axon, dendrite
# get the upstream connectivity
hl_us <- flywire_partner_summary(hl_fwid, partners = 'inputs')

# Plot number of weak and strong partners (where weak corresponds to <1% of target’s synapses accounted for by an upstream partner and strong is >= 1%) in axon and dendrites separately
# fw_meta has dend input and outputs
