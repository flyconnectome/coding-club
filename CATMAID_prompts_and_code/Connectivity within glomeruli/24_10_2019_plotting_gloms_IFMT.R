
library(natverse)

all_vol_list <- catmaid_get_volumelist()

# Filters the gloms, although it still keeps the gloms that have the '_new' at the end...
dplyr::filter(all_vol_list, !grepl("_L|neuropil|glomerulus|allLayer|right|ORNs", all_vol_list$name), 
              grepl("^v14.", all_vol_list$name)) -> glom_filtered

# maybe a for loop (apply function) to incorporate the '_new' volumes???

# fetch the volumes
glom_vol <- lapply(glom_filtered$id, catmaid_get_volume)

# Plot
# I still don't understand shade3d()
mapply(shade3d, glom_vol, col= rainbow(length(glom_vol)), alpha=0.5)


# ignore the following
# How to quickly check the type of data you are working with? like type() in python

# What is the difference between the following?
mapply()
sapply()
lapply


