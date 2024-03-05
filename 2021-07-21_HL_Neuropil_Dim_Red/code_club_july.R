library(tidyverse)
library(nat)
library(nat.nblast)
library(ggplot2)
library(fafbseg)
library(dendroextras)
library(Rtsne)
library(gridExtra)

path <- "https://docs.google.com/spreadsheets/d/1QyuHFdqz705OSxXNynD9moIsLvZGjjBjylx5sGZP2Yg/"

# 1.1 Read neurons of the hemilineage AOTUv4_ventral  in the
# fafb_hemilineages_survey_right sheet.
fafb_hemi <- googlesheets4::read_sheet(path, sheet = "ItoLee_Hemilineage_AOTUv4_ventral_right")

# 1.2 Remove duplicates and choose complete/adequate neurons for further analyses.
fafb_hemi_cl <- fafb_hemi %>% filter(ItoLee_Hemilineage == "AOTUv4_ventral") %>%
  filter(status %in% c("complete", "adequate"))

duplicated(unlist(fafb_hemi_cl$skid))

bodyids <- unlist(fafb_hemi_cl$skid)

duplicated(fafb_hemi_cl$flywire.id)

fafb_hemi_cl <- fafb_hemi_cl[!duplicated(fafb_hemi_cl$flywire.id),]

# 1.3 Prune/simplify neurons as you see fit and divide into distinct
# morphological types.

fafb_nrns <- fafbseg::skeletor(fafb_hemi_cl$flywire.id)
fafb_nrns <- readRDS("cc_neurons.rds")
fafb_nrns <- nlapply(fafb_nrns/1e3, reroot_hairball)
fafb_nrns2 <- nlapply(fafb_nrns, function(x) simplify_neuron(x, n=4))

dps <- dotprops(fafb_nrns2)
aba_scores <- nblast_allbyall(dps, normalisation = "normalise")

hc <- nhclust(scoremat = aba_scores)

plot(hc, labels = F)
h_cutoff <- 2
ct <- cutree(hc, h = h_cutoff)
hcc <- colour_clusters(hc, h=h_cutoff)
plot3d(hc, db=fafb_nrns2, h=h_cutoff, soma=T)

fafb_nrns2[,"cluster"] <- ct

k_clusters <- max(unique(fafb_nrns2[,]$cluste))

#fafb_nrns2 <- readRDS("cc_neurons.rds")

# 2.1 Find the downstream and upstream connections for each neuron.
fw_syn <- flywire_partners(fafb_nrns2[,"id"], details=TRUE)
#fw_syn <- readRDS("cc_synapses.rds")
fw_syn$X <- (fw_syn$pre_x + fw_syn$post_x)/2
fw_syn$Y <- (fw_syn$pre_y + fw_syn$post_y)/2
fw_syn$Z <- (fw_syn$pre_z + fw_syn$post_z)/2
fw_syn <- fw_syn %>% mutate(is_pre = ifelse(query == pre_id, 1, 0))

plot3d(fafb_nrns2, add=T)
plot3d(xyzmatrix(fw_syn)/1e3)

# 2.2  Write a function which returns the percentage of innervation of a given neuron in different neuropil
FAFBsurf <- elmr::FAFB14NP.surf/1e3

innervation_per_neuropil <- function(points, surfaces) {
  regions <- surfaces$RegionList
  sapply(regions,
         function(x) sum(pointsinside(points, surf=subset(surfaces, x))))
}

# 3.3 Find which neuropil each neuron innervates. Obtain a dataframe with
# the percentage of innervation (percent connections in a given neuropil region)
# in each neuropil for each neuron.
np_counts <- lapply(1:length(fafb_nrns2),
  function(x)
    innervation_per_neuropil(
      xyzmatrix(fw_syn %>% filter(query == fafb_nrns2[x,"id"]))/1e3,
      FAFBsurf
    )
)

# 4.1 Obtain a feature matrix where the rows are the neuron ids and columns
# are neuropil regions and each cell is the percentage of synapses of that
# neuron in that particular neuropil region.

feat_mat <- map_dfr(np_counts, ~.x)
col_zeros <- names(which(colSums(feat_mat) == 0))
nonempty_cols <- setdiff(colnames(feat_mat), col_zeros)
feat_mat_sc <- sweep(as.matrix(feat_mat), 1, rowSums(feat_mat), `/`)

# 3.2 Plot and compare the percentage innervations in each neuropil
# for the different morphological types (brownie points if data is
# segregated by input & output synapses and/or axon & dendrites)

barplots <- lapply(1:k_clusters, function(k)
  feat_mat[which(fafb_nrns2[,"cluster"] == k), nonempty_cols] %>%
      colSums() %>% as.data.frame() %>%
      setNames("counts") %>%
      rownames_to_column("NP") %>%
      ggplot(aes(x=NP, y=counts, fill=NP)) +
        geom_bar(stat="identity") +
        theme(legend.position = "none") +
        theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))
)

do.call("grid.arrange", c(barplots, ncol = 3))

# 4.2 Apply TSNE/UMAP to reduce dimensions and see if morphological types
# cluster together according to their innervation patterns.

tsne_out <- Rtsne(feat_mat_sc[,nonempty_cols], pca=T, perplexity=3, theta=0.0)
coln <- RColorBrewer::brewer.pal(length(unique(fafb_nrns2[,]$cluster)),"Spectral")
names(coln) <- unique(fafb_nrns2[,]$cluster)
plot(tsne_out$Y,col=coln[fafb_nrns2[,]$cluster], asp=1)
title('tSNE')

pca_out <- prcomp(feat_mat_sc[,nonempty_cols])
plot(pca_out$x[,1:2],col=coln[fafb_nrns2[,]$cluster])
title('PCA')

