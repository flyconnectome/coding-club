library(natverse)
library(fafbseg)
library(tidyverse)
library(reticulate)
library(hemibrainr)
library(ggplot2)
library(dendextend)
library(clipr)
library(randomcoloR)

flytable_login(
  url = "https://flytable.mrc-lmb.cam.ac.uk/",
  token = Sys.getenv("FLYTABLE_TOKEN", unset = NA_character_)
)

info <- flytable_list_rows("info")
rings <- info %>% filter(cell_class == "ring neuron" & root_duplicated == F) %>% select(root_id, supervoxel_id, soma_x, soma_y, soma_z, nucleus_id,pos_x, pos_y, pos_z, cell_type, side)

length(unique(rings$cell_type)) #total unique morphological ER types.

#L2 skels and reading from folder where neurons are stored.
write_clip(rings$root_id) #for L2 skeletonisation in python
rsk <- read.neurons("/Users/varunaniruddhasane/rings")

#because rsksyns and rings was differently sorted, i need to resort. converting to L2, storing in a folder and reading somehow changed the order.
rings %>% arrange(factor(root_id, levels = names(rsk))) -> rings_sorted 


#wouldve created problems in rerooting l2 skels. rerooting necessary for flow centrality calculation to figure out axon dendrite split.
rsk_soma <- reroot(rsk, point = flywire_raw2nm(rings_sorted[c("soma_x", "soma_y", "soma_z")])) #rerooting to give soma locations from info table 
rsksyns <- flywire_neurons_add_synapses(rsk_soma, cleft.threshold = 50) #fetching and attaching synapses on L2 skeletons
# write.neurons(rsksyns, "/Users/varunaniruddhasane/rings_syns")
# read_rsks <- read.neurons("/Users/varunaniruddhasane/rings_syns")
# plot3d_split(rsksyns[1:5],WithConnectors = T)
rsk_flow <- flow_centrality(rsksyns, mode = "centrifugal", polypre = T, soma = T) #compute flow centrality. dont know how different modes vary. 

# plot3d_split(rsk_flow[1:10],WithConnectors = T)
# plot3d(FAFB14, alpha =  0.1)

# table(rsk_flow$`720575940602783968`$d$Label %in% c(2))
# View(rsk_flow$`720575940602783968`$d)

rsk_nodend <- nlapply(rsk_flow, function(x) subset(x, x$d$Label !=3)) #remove dendritic branches. dendrites have label = 3, axons have label = 2. other labels for primary neurite, linker as well.
rsk_notEB <- prune_in_volume(rsk_nodend, surf = FAFB14NP.surf, neuropil = "EB", invert = F) #pruning everything not part of the EB.
rsk_st <- nlapply(rsk_notEB, stitch_neurons_mst) #stiching neurons so that they arent random neuron fragments floating anywhere.

# checking neuron morphologies
plot3d_split(rsk_flow[1]) #neuron, split into arbour compartments
plot3d(rsk_nodend[1], lwd = 5, alpha = 0.5, col = "red") #neuron with dendrites removed.
plot3d(rsk_notEB[1], lwd = 5, alpha = 0.7, col = "green") #dend removed neuron wiht everything outside the EB
plot3d(rsk_st[1:10], lwd = 1,  col = "green") #plotting the stitched up neuron.
plot3d(FAFB14NP.surf, alpha = 0.1) #plot FAFB volume for reference.

#compute length of primary neurite of stitched up neuron. what is the unit?
rskinfo <- nlapply(rsk_st, function(x) spine(x,rval = "length")) %>% unlist() %>% as.data.frame() 
rskinfo %>% rownames_to_column(var = "neuron") %>% rename(length = '.') -> rskinfo #formatting column names of dataframe for easier access later. 

#nblastallbyall
rskdps <- dotprops(rsk_st/1e3, k=5, resample = 1) #convert to dotprops
nb <- nblast_allbyall(rskdps)
nhclust <- nhclust(nb)
dend <- as.dendrogram(nhclust)
plot(dend)
heights_per_k.dendrogram(dend) #gives heights at which dendrogram breaks into two
#total 11 Er subtypes so dividing into 22 groups. not one to one correspondence b/w morph and ER type, but should suffice.
dend1 <- colour_clusters(dend,h=1.5270814) #colour the denrogram at what height
plot(dend1)

# input number of groups to divide dend into. based on heights_per_k.dendrogram 
grps = readline("Groups = ") 

# empty dataframe to assign data into. would contain all info. probably not necessary to have a new dataframe. done for ease.
rskinfo_full <- data.frame()

# giving nbaslt groups to ids and storing in datafrmae
# loop through all groups, subset the  dendrogram based on the the height(at which the number of groups we selected exist) and extract the rootids per group.
# bind that into a dataframe with some extra info. 
rskinfo_full <- rbindlist(lapply(c(1:grps), function(x){
  data.frame(neuron = subset(nhclust, k = grps, groups = x), group = x)
})) %>% as.data.frame() %>% merge(rskinfo, by.x = "neuron", by.y= "neuron", sort = F) %>% merge(rings_sorted[c("root_id", "cell_type", "side")], by.x = "neuron", by.y = "root_id", sort = F)

# create colour vector with distinct colours which are as different from each other as possible.gives a different col vector each time its run
distcol <- distinctColorPalette(k=length(unique(rskinfo_full$cell_type)))
names(discol) <- unique(rskinfo_full$cell_type) #would make this a named vector giving ER types a colour based on the group (in the order that they appear in list of unique cell types).

#test plot. not important
#to plot celltype_side as a group.
rskinfo_full %>% mutate(ring_side = paste0(cell_type,"_",side)) %>%
ggplot() +
  aes(x = reorder(group, length), y = length, colour = ring_side) +
  geom_point(size = 1L) +
  labs(x = "Group", y = "Length") +
  theme_minimal()

#test plot. not important
# plot cell type and side with unique identifier in colour and shape.
ggplot(rskinfo_full) +
  aes(x = reorder(group, length), y = length, colour = cell_type, shape = side) +
  geom_point(size = 3) + scale_colour_manual(values = distcol) +
  labs(x = "Group", y = "Length") +
  theme_minimal()

#test plot, faced with side with stats. using stat_summary to find mean and standard deviation. plotting mean with mean ± sd as limits (using pointrange) with lower alpha. 
# also using asterisk for shape of mean point 
ggplot(rskinfo_full) +
  aes(x = reorder(cell_type, length), y = length, colour = cell_type) +
  geom_point(size = 3) + scale_colour_manual(values = distcol) + 
  stat_summary(fun = mean, fun.min = function(x) mean(x) - sd(x), fun.max = function(x) mean(x) + sd(x), geom = "pointrange", 
               colour = "blue", size = 0.75, shape = 8, alpha = 0.5) +
  labs(x = "ER_type", y = "Length", colour = "Cell type") + theme(axis.ticks.x = element_blank()) + facet_wrap(vars(side))

# plot of length vs cell type shaped by side with mean ± sd using pointrange. guides allows legends formatting (need it in one row).  
ggplot(rskinfo_full) +
  aes(x = reorder(cell_type, length), y = length, colour = cell_type, shape = side) +
  geom_point(size = 3) + scale_colour_manual(values = distcol) + 
  stat_summary(fun = mean, fun.min = function(x) mean(x) - sd(x), fun.max = function(x) mean(x) + sd(x), geom = "pointrange", 
               colour = "blue", size = 0.75, shape = 8, alpha = 0.5) + guides(colour = guide_legend(nrow = 1)) +
  labs(x = "ER_type", y = "Length", colour = "Cell type") + theme(axis.ticks.x = element_blank()) -> grpbycelltype

# plot of length vs group, grouped by cell type, shaped by side with mean ± sd using pointrange. guides allows legends formatting (need it in one row).
ggplot(rskinfo_full) +
  aes(x = reorder(group, length), y = length, colour = cell_type, shape = side) +
  geom_point(size = 3) + scale_colour_manual(values = distcol) +
  stat_summary(fun = mean, fun.min = function(x) mean(x) - sd(x), fun.max = function(x) mean(x) + sd(x), geom = "pointrange", 
               colour = "blue", size = 0.75, shape = 8, alpha = 0.5) + guides(colour = guide_legend(nrow = 1)) +
  labs(x = "Group", y = "Length", colour = "Cell type") + theme(axis.ticks.x = element_blank(), axis.text.x = element_blank()) -> grpbymorph 

#dend2 so that dend stays safe and unmodified; not necessary.
dend2 <- dend
# labels_colors colours the labels of dendro with colours based on named vector distcol for all cell types ordered by dendrogram
labels_colors(dend2)<-distcol[rskinfo_full$cell_type][order.dendrogram(dend2)]
ggplot(dend2) -> d3 #using ggplot to make a ggplot object for grid arrangement later.

# ggarrange allows grid arrange. nested ggarrange allows custom ggrrangement.  
ggpubr::ggarrange(ggpubr::ggarrange(grpbycelltype, grpbymorph ,common.legend = T, ncol = 2), d3,  nrow = 2, labels = c("","Dendrogram")) -> arrangedplt
arrangedplt
