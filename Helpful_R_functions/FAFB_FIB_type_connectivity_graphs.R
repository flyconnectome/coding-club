# making FIB FAFB connectivity comparisons based on Drive annotation lists
# 2020. 04. 15. Istvan Taisz

# useful tips on how to use ggnetwork: https://cran.r-project.org/web/packages/ggnetwork/vignettes/ggnetwork.html

# update frequently:
# remotes::install_github("natverse/neuprintr")
# remotes::install_github("jefferislab/catnat")
library(natverse)
library(neuprintr)
library(catnat)
library(ggnetwork)
library(network)
library(dplyr)
library(googledrive)
library(googlesheets4)
library(ComplexHeatmap)
library(sna)

# First you need to make a sheet on the googledrive with your neurons' "skid" / "bodyid" and "type"
# because the number of neurons in a type can vary, and we don't have everything in both datasets, I just made separate sheets for FAFB and FIB for simplicity
# the drive spreadsheet can be also replaced with a csv from your machine or any other way where you end of with adataframe that has these columns: "skid" or "bodyid", "type"
# in the case of the cVA circuit many types exist on both sides of FAFB, this is noted in the "FAFB_skids_cVA" spreadsheet in column "side" by R and L, and used downstream


sheets  = drive_find(type = "spreadsheet") # log in with google account that has access to the shared drive
# find IDs for sheets
FIB_bids_id = sheets$id[sheets$name == "FIB_bids_cVA"] # your spreadsheet with FIB types
FAFB_skids_id = sheets$id[sheets$name == "FAFB_skids_cVA"] # your spreadsheet with FAFB types
# read sheets into dataframes
FIB_bids = read_sheet(FIB_bids_id)
FAFB_skids = read_sheet(FAFB_skids_id)

# Checkpoint:
# list type names; matching neurons should have the same type name
names(table(FIB_bids$type))
names(table(FAFB_skids$type))
intersect(names(table(FIB_bids$type)), names(table(FAFB_skids$type)))

# genereate connectivity matrices and heatmaps based on subsetting by types

# add the specific type names that you want on your graph (e.g. in cVA circuit there are 36 types that exist in both datasets, I want only some of those)
types = c("DA1 uPN mALT", "DA1 mPN T1b", "aSP-g a", "aSP-g p", "mAL Spike 1", "mAL Spike 2", "Moose")

# getting skids for RHS, LHS, full FAFB, FIB for types
FAFB_RHS_skids1 = FAFB_skids[FAFB_skids$side == "R" & FAFB_skids$type %in% types, ]
FAFB_LHS_skids1 = FAFB_skids[FAFB_skids$side == "L" & FAFB_skids$type %in% types, ]
FAFB_skids1 = rbind(FAFB_RHS_skids1, FAFB_LHS_skids1)
FIB_bids_1 = FIB_bids[FIB_bids$type %in% types, ]

# fetching connectivity matrices with individual neurons - not necessary
# FAFB_RHS_cm = connectivity_matrix(FAFB_RHS_skids1$skid)
# FAFB_LHS_cm = connectivity_matrix(FAFB_LHS_skids1$skid)
# FAFB_cm = connectivity_matrix(FAFB_skids1$skid)
# FIB_cm  = neuprint_get_adjacency_matrix(FIB_bids_1)


# function to fetch connectivity matrices by type from a dataframe with skids or bodyids and type names
# argument -dataset- can have values "FAFB" or "FIB"; decides which function to use to fetch matrix

conn_mat_by_type = function (df, dataset, ...) {
  if (!is.data.frame(df)) {
    stop("Dataframe expected with columns named type and skid (FAFB) or bodyid (FIB)")
  }
  if (dataset == "FAFB"){
    conn_mat = connectivity_matrix(df$skid)
  }
  if (dataset == "FIB"){
    conn_mat = neuprint_get_adjacency_matrix(df$bodyid)
  }
  
  conn_mat_comp = conn_mat
  rownames(conn_mat_comp) = colnames(conn_mat_comp) = df$type
  conn_mat_comp = t(apply(t(conn_mat_comp), 2, function(x) tapply(x, colnames(conn_mat_comp), sum, na.rm = TRUE)))
  conn_mat_comp = apply(conn_mat_comp, 2, function(x) tapply(x, rownames(conn_mat_comp), sum, na.rm = TRUE))
  conn_mat_comp
}

FAFB_RHS_cm_t = conn_mat_by_type(FAFB_RHS_skids1, dataset = "FAFB")
FAFB_LHS_cm_t = conn_mat_by_type(FAFB_LHS_skids1, dataset = "FAFB")
FAFB_cm_t = conn_mat_by_type(FAFB_skids1, dataset = "FAFB")
FIB_cm_t = conn_mat_by_type(FIB_bids_1, dataset = "FIB")

# quick look on type connectivity matrix with heatmap; no clustering is done - order of types is consistent
Heatmap(FAFB_RHS_cm_t, col = c("white","black"), cluster_rows = F, cluster_columns = F)
Heatmap(FAFB_LHS_cm_t, col = c("white","black"), cluster_rows = F, cluster_columns = F)
Heatmap(FAFB_cm_t, col = c("white","black"), cluster_rows = F, cluster_columns = F)
Heatmap(FIB_cm_t, col = c("white","black"), cluster_rows = F, cluster_columns = F)

# generate consistent graphs

# give manual x, y coordinates for network layout

# NOTE:
# if two nodes have the same x or y coordinates the weight of the link between them won't be displayed (looks like a bug in the ggnetwork package)
# that's why many nodes have a tiny offset from a round value

# for adjusting the values plot your graph with theme_classic() instead of theme_blank(), this gives you x, y axes
# the exact x, y values are not what you give, they are transformed with the ggnetwork function
# the nodes that are most "lateral" will fall onto the sides of a 1:1 square, with coordinates [0.5, 0.5] in the middle (easier to plot than explain)

xy_mat  = matrix(NA, length(types), 2)
rownames(xy_mat) = sort(types) # network() sorts nodes alphabetically
colnames(xy_mat) = c("a", "b")

xy_mat[1, ] = c(0.45, 0.55) # aSP-g a
xy_mat[2, ] = c(0.55, 0.5499999909) # aSP-g b
xy_mat[3, ] = c(0.60, 0.6499999999) # DA1 mPN T1b # small offset from 0.65 solves edge label missing issue
xy_mat[4, ] = c(0.40, 0.65) # DA1 uPN mALT
xy_mat[5, ] = c(0.5, 0.45) # mAL Spike 1
xy_mat[6, ] = c(0.65, 0.4) # mAL Spike 2
xy_mat[7, ] = c(0.35, 0.4) # Moose
# add more rows, if you have more types

setwd("/Users/itaisz/Documents/GitHub/2020cva/analysis/")


thr = 5 # edge threshold to plot on network (higher than this will be shown)


# plot titles and pdf file names to loop through
title_list = c("FAFB RHS", "FAFB LHS", "FAFB sum", "hemibrain")
title_list_pdf = c("FAFB_RHS", "FAFB_LHS", "FAFB_sum", "hemibrain")

mat_list = list(FAFB_RHS_cm_t, FAFB_LHS_cm_t, FAFB_cm_t, FIB_cm_t)



# useful options:

# arrow.gap
# curvature
# lwd_weight - now the linewidth is proportional to the square root of the weight
# scale_size_area(max_size = 15) -  this is what actually sets the nodesize now
# theme(plot.title = element_text(face = "bold", color = "grey", size = 18, hjust = 0.5, vjust = 10))
# theme(plot.margin = unit(c(2,1,1,1), "cm"))


for(i in 1:4){
  network = network(mat_list[[i]],
                    matrix.type = "adjacency",
                    ignore.eval = FALSE,
                    names.eval = "weight",
                    directed = TRUE,
                    loops = TRUE)
  
  n = ggnetwork(network, arrow.gap = 0.04, layout = xy_mat) 
  
  lwd_weight  = sqrt(na.omit(n[n$weight > thr,]$weight)/15)
  
  filename = paste( title_list_pdf[i], "_subtype_graph.pdf", sep = "")
  
  plot_i = ggplot(n[is.na(n$weight) | n$weight > thr,], aes(x = x, y = y, xend = xend, yend = yend)) +
    geom_edges(aes(color = vertex.names),
               curvature = 0.12,
               arrow = arrow(length = unit(6, "pt"),
                             type = "closed"), lwd  = lwd_weight) +
    geom_nodes(aes(color = vertex.names, size = 100)) +
    geom_edgetext(aes(label = weight, color = vertex.names), fill = NA) +
    geom_nodelabel_repel(aes(color = vertex.names, label = vertex.names),
                         fontface = "bold") +
    scale_size_area(max_size = 15) +
    theme_classic() + 
    guides(color = FALSE, shape = FALSE, fill = FALSE, size = FALSE, linetype = FALSE) + 
    theme(plot.title = element_text(face = "bold", color = "grey", size = 18, hjust = 0.5, vjust = 10)) +
    theme(plot.margin = unit(c(2,1,1,1), "cm")) +
    ylab("") + 
    xlab("") +
    ggtitle(title_list[i])
  
  pdf(file = filename, height = 7, width = 7)
  print(plot_i)
  dev.off()
}
