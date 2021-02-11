# This script intends to: 
# Get all the upstream neurons for Flywalkies
# Subset a data frame of the upstream neurons into these four categories [uPN, mPN, MBON and Other] 
# Create a data frame of the percentage of upstream neurons in the categories

library(natverse)

conn = catmaid_login()

# Get FlyWalkies and its partners 
flw = read.neurons.catmaid('annotation:Multiglomerular mALT PN 32794 Flywalkies JMR')
flw_partners = catmaid_query_connected(flw[[1]]$skid)

# Annotations for upstream partners 
upstream_annotations = catmaid_get_annotations_for_skeletons(flw_partners$incoming$partner) 
# I later realised that by doing this, I'm eliminating the neurons without annotations 
upns <- data.frame(
  skid = unique(upstream_annotations$skid[grepl('WTPN2017_uPN',upstream_annotations$annotation)]), 
  category = 'uPN') 
mpns <- data.frame(
  skid = unique(upstream_annotations$skid[grepl('WTPN2017_mPN',upstream_annotations$annotation)]), 
  category = 'mPN')
mbons <- data.frame(
  skid = unique(upstream_annotations$skid[grepl('MBON',upstream_annotations$annotation)]), 
  category = 'MBON')
pns_mbons.info = rbind(upns, mpns, mbons)

# Other skids 
other <- setdiff(unique(upstream_annotations$skid), pns_mbons.info$skid)
# Again the line above doesn't include skids that don't have annotations. So what should've happened is: 
# other <- setdiff(unique(flw_partners$incoming$partner), pns_mbons.info$skid)

# Put all skids together 
up_partners = data.frame(
  skid = c(pns_mbons.info$skid, other), 
  annotation = c(pns_mbons.info$category, rep('Other', length(other)))
)
# data frame of the percentage of upstream neurons 
df <- data.frame(
  category = c('uPN','mPN','MBON','Other'), 
  percentage = c(sum(grepl('uPN', up_partners$annotation))/nrow(up_partners), 
                 sum(grepl('mPN', up_partners$annotation))/nrow(up_partners),
                 sum(grepl('MBON', up_partners$annotation))/nrow(up_partners), 
                 sum(grepl('Other', up_partners$annotation))/nrow(up_partners))
)

# However there are duplicated ids in pns_mbons.info, meaning some neurons are given multiple cell types 
# To get them: 
dup <- pns_mbons.info$skid[duplicated(up_partners$skid)]
# And see their types: 
pns_mbons.info[pns_mbons.info$skid %in% dup,]
# Plot them with the surface mesh: 
weird <- read.neurons.catmaid(dup)
plot3d(weird)
plot3d(FAFB.surf, add = TRUE, alpha = 0.1)
# And they don't look like MBONs, so let's delete those rows 
pns_mbons.info <- pns_mbons.info[!duplicated(pns_mbons.info$skid),]

# Plot neurons of the first 3 categories 
# Get them from catmaid 
pns_mbons <- read.neurons.catmaid(pns_mbons.info$skid)
plot3d(pns_mbons, col = as.factor(pns_mbons.info$category))
