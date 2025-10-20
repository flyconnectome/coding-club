library(fafbseg)
library(dplyr)
library(ggplot2)
library(tidyverse)
library(natverse)
library(nat.nblast)
library(coconat)

choose_aedes()

source("R/funs/aedes-dataset-funs.R")

##manipulate data and choose only right side neurons
alpn=flytable_query("select * from aedes_main where class='ALPN' AND status NOT IN ('duplicate','fragment', 'tiny')")
alpn_ids=alpn$root_id
alpn_R_ids <- alpn$root_id[alpn$side == "R"]
alpn_L_ids <- alpn$root_id[alpn$side == "L"]

##Retrieve neurons as simplified dotdrops via FlyWire
alpndps=read_l2dp(alpns)
alpndps_R=read_l2dp(alpn_R_ids)
alpndps_L=read_l2dp(alpn_L_ids)

##mirror neurons
mirrored_alpns=xform(alpndps_R, reg = aedes_mirroreg())

plot3d(alpndps_L, col = "red", lwd = 2)
plot3d(mirrored_alpns, col = "blue", lwd = 2, add = TRUE)

mirrored_alpns_all<- c(mirrored_alpns, alpndps_L)

##run nblast and clustering
alpns_nblast=nblast_allbyall(mirrored_alpns_all)
alpns_hc=nhclust(scoremat=alpns_nblast)

###Plotting

##add required labels to the plot
alpns_labels <- paste(alpn$root_id,
                      alpn$side,
                      alpn$group,
                      alpn$type,
                      sep = "_")

alpns_hc$labels <- alpns_labels

pdf("dendrogram_alpns.pdf", width = 150, height = 200)
par(mar = c(15,7,4,2), family = 'Courier', font = 2)

plot(as.dendrogram(alpns_hc),
     main = "ALPNs NBLAST Clustering",
     ylab = "Height",
     leaflab = "perpendicular",
     cex = 0.5,
     cex.main = 3,
     cex.lab = 2
)
dev.off()
system("open .")
