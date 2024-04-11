library(natmanager)
library(natverse)
library(fafbseg)
library(malevnc)
library(malecns)
library(tidyverse)
library(fafbseg)
library(reticulate)
library(natverse)
library(googlesheets4)
library(dplyr)
library(elmr)
library(clipr)
library(reshape2)
library(ComplexHeatmap)
library(tidyr)
library(RCy3)
library(plyr)
library(nat)
library(igraph)
library(gplots)
library(RColorBrewer)
library(circlize)

---
  title: "For_Ilina"
output: html_notebook
editor_options: 
  chunk_output_type: inline
---
  For CamNeuro poster: strating with a set of 12 ANs, 2 types
# Setup
```{r}
# libraries
```
# Read in data
## mcns DVID/clio
Get annotations in DVID/clio, for all bodies.
```{r}
mda = mcns_dvid_annotations()
mda$bodyid <- as.character(mda$bodyid)
```
# Read MANC DVID/Clio
manc v1.0 is the default
```{r}
choose_malevnc_dataset('VNC')
mancanno = malevnc::manc_body_annotations()
# malevnc:::choose_malevnc_dataset('MANC')
```
# My ids
```{r}
my_ids_manc <- c(11260L, 10823L, 12834L, 20216L, 10516L, 10925L, 10295L, 10426L, 10540L, 10687L, 10418L, 10443L)
# in mcns
my_ids <- c(93227L, 82880L, 78114L, 98764L, 46240L, 66800L, 31227L, 41101L, 800658L, 37217L, 26680L, 26278L)
# my_ids = scan()
# 1: 93227
# 2: 82880
# 3: 78114
# 4: 98764
# 5: 46240
# 6: 66800
# 7: 31227
# 8: 41101
# 9: 800658
# 10: 37217
# 11: 26680
# 12: 26278
# 13: 
```
# # Full connectivity by roi
# Connectivity table for all neurons, and rois, by roi.
# ```{r}
# my_ids_conn = mcns_connection_table(ids = my_ids, partners = c("inputs", "outputs"), moredetails = c("group", "class", "mancBodyid", "mancGroup"), by.roi = T)
# 
# my_ids_conn = mcns_connection_table(ids = my_ids, partners = "outputs", moredetails = c("group", "class", "mancBodyid", "mancGroup"), by.roi = T)
# my_ids_conn2 = mcns_connection_table(ids = my_ids, partners = "inputs", moredetails = c("group", "class", "mancBodyid", "mancGroup"), by.roi = T)
# my_ids_conn <- data.table::rbindlist(list(my_ids_conn, my_ids_conn2), fill = TRUE)
# 
my_ids_target = malevnc::manc_connection_table(ids = my_ids_manc, moredetails = "neuprint", by.roi = T)
# my_ids_target$bodyid <- as.character(my_ids_target$bodyid)
# str(my_ids_target)
# 
# my_ids_conn$bodyid <- as.character(my_ids_conn$bodyid)
# ```
# ```{r}
# str(my_ids_conn)
```



## Outputs
Get outputs.
```{r}
my_ids_outconn = mcns_connection_table(ids = my_ids, partners = "outputs", moredetails = c("group", "class", "somaSide", "mancBodyid", "mancGroup"), by.roi = T)
my_ids_outconn$bodyid <- as.character(my_ids_outconn $bodyid)
my_ids_outconn$mancGroup <- as.character(my_ids_outconn$mancGroup)
```
## Inputs
Get inputs.
```{r}
my_ids_inconn = mcns_connection_table(ids = my_ids, partners = "inputs", moredetails = c("group", "class", "somaSide", "mancBodyid", "mancGroup"), by.roi = T)
my_ids_inconn$bodyid <- as.character(my_ids_inconn$bodyid)
my_ids_inconn$mancGroup <- as.character(my_ids_inconn$mancGroup)
```
## Join the 2 for full df
rbind the 2
```{r}
my_ids_conn <- bind_rows(my_ids_outconn, my_ids_inconn)


Left join to add metadata for bodyid. manc_group or manc_type can be used as type.
Rename columns so as not to confuse partner and bodyid metadata.
Create column for partner type that takes into account if there is a type already, if not a manc_group, if not a group.
```{r}

my_ids_conn %>%
  dplyr::rename(pt_name = name,
         pt_type = type,
         pt_group = group,
         pt_class = class,
         pt_soma_side = somaSide,
         pt_manc_bodyid = mancBodyid,
         pt_manc_group = mancGroup
  ) %>% 
  left_join(select(mda, bodyid, manc_group, manc_type), by = "bodyid") %>% 
  select(bodyid, partner, manc_group, manc_type, prepost, weight, roi, ROIweight, pt_name, pt_type, pt_group, pt_class, pt_manc_bodyid, pt_manc_group) %>% 
  mutate(pt_manc_group = as.character(pt_manc_group),
         pt_group = as.character(pt_group),
         pt_typej = case_when(
           !is.na(pt_type) ~ pt_type, 
           (is.na(pt_type) & !is.na(pt_manc_group)) ~ pt_manc_group,
           (is.na(pt_type) & !is.na(pt_group)) ~ pt_group,
           TRUE ~ NA)) %>% 
  select(bodyid:pt_type, pt_typej, everything()) -> ans_conn

```
# Outputs in the brain
Filter for brain and outputs.
```{r}
ans_conn_outbrain <- ans_conn %>% 
  filter(roi != "vnc-shell") %>% 
  filter(prepost == 0)

ans_conn_outbrain[order(ans_conn_outbrain$bodyid, ans_conn_outbrain$weight, decreasing = T),] -> display
ans_conn_outbrain_top <- display %>% group_by(bodyid) %>% slice_head(n=2)


ans_conn_outbrain_filtered <- filter(ans_conn_outbrain, weight >= 10)

ans_conn_invnc_top <- ans_conn_invnc[order(ans_conn_invnc$bodyid, ans_conn_invnc$weight, decreasing = T),] %>% group_by(bodyid) %>% slice_head(n=3)
ans_conn_outvnc_top <- ans_conn_outvnc[order(ans_conn_outvnc$bodyid, ans_conn_outvnc$weight, decreasing = T),] %>% group_by(bodyid) %>% slice_head(n=3)


ans_conn_outvnc_top_unique <- group_by(ans_conn_outvnc_top, partner) %>% slice_head(n=1)
#ans_conn_outvnc_top_unique$pt_class[ans_conn_outvnc_top_unique$pt_class == 'vnc_tbc'] <- 'intrinsic_neuron'
ans_conn_outvnc_top_unique <- ans_conn_outvnc_top_unique[order(ans_conn_outvnc_top_unique$pt_class),]
heatmap_matrix <- neuprint_get_adjacency_matrix(inputids = ans_conn_outvnc_top_unique$partner, outputids = ans_conn_outvnc_top_unique$bodyid, dataset = "cns")

target_data <- my_ids_target[match(ans_conn_outvnc_top_unique$pt_manc_bodyid, my_ids_target$partner),]$target
origin_data <- my_ids_target[match(ans_conn_outvnc_top_unique$pt_manc_bodyid, my_ids_target$partner),]$origin

row_anno <- rowAnnotation(Class = ans_conn_outvnc_top_unique$pt_class, Target = target_data, col = list(Class = colours))
col_fun = colorRamp2(c(0, 400), c("darkblue", "yellow"))

unique_class <- unique(ans_conn_outvnc_top_unique$pt_class)
colours_class <- RColorBrewer::brewer.pal(n= length(unique_class), name = "Set1")
tmp = as.data.frame(colours_class)
rownames(tmp) <- unique_class
tmp<-list(tmp$colours_class)

tmp <-list(bar = c("a" = "red", "b" = "green", "c" = "blue"))

Heatmap(heatmap_matrix, name = "Weight", right_annotation = row_anno, col = col_fun)

ans_conn_out_tar_brain <- my_ids_target %>% 
  filter(roi != "vnc-shell") %>% 
  filter(prepost == 0)

ans_conn_out_tar_vnc <- my_ids_target %>% 
  filter(roi == "vnc-shell") %>% 
  filter(prepost == 0)

ans_conn_out_tar[order(ans_conn_out_tar$bodyid, ans_conn_out_tar$weight, decreasing = T),] -> display
ans_conn_out_tar_top <- display %>% group_by(bodyid) %>% slice_head(n=3)

# Outputs in the VNC

ans_conn_outvnc <- ans_conn %>% 
  filter(roi == "vnc-shell") %>% 
  filter(prepost == 0)



#Inputs in the VNC

ans_conn_invnc <- ans_conn %>% 
  filter(roi == "vnc-shell") %>% 
  filter(prepost == 1)

```
Any without a class
```{r}

ans_conn_outvnc_expo <- ans_conn_outvnc %>% group_by(bodyid) %>% slice_head(n=10)

ans_conn_outvnc_expo %>% 
  filter(is.na(pt_class)) %>% with(write_clip(partner))
```
## totals by brain ROI
Tot up by brain ROI
```{r}
pie <- ans_conn_outbrain %>% 
  dplyr::count(roi, wt = ROIweight, name = "ROiweight") %>% 
  arrange(desc(ROiweight))
```

#pie
ggplot(pie, aes(x= "", y=ROiweight, fill = roi)) + geom_bar(stat="identity", width=1, color = "white") + coord_polar("y", start =0) + theme_void()

## totals by partner class
Tot up by partner class.
```{r}
pie2 <- ans_conn_outbrain %>% 
  dplyr::count(pt_class, sort=T)
ggplot(pie2, aes(x= "", y=n, fill = pt_class)) + geom_bar(stat="identity", width=1, color = "white") + coord_polar("y", start =0) + theme_void()
```
Calculate percentage.
```{r}
ans_conn_outbrain %>% 
  #filter(complete.cases(pt_class)) %>% 
  dplyr::group_by(pt_class) %>%
  summarize(n = n()) %>%
  dplyr::mutate(pt_class_pct = round(n / sum(n) * 100, 0)) %>% 
  arrange(desc(pt_class_pct))
```

##printneurons

anc_conn_outbrain_filtered <- filter(ans_conn_outbrain, weight >= 8)
unique_data <- anc_conn_outbrain_filtered %>% group_by(partner) %>% slice_head(n=1)

unique_data_outbrain_AN07B005 <- ans_conn_outbrain %>% filter(manc_type == "AN07B005")
unique_data_outbrain_AN07B005 <- unique_data_outbrain_AN07B005[order(unique_data_outbrain_AN07B005$weight, decreasing = T),] %>% slice_head(n=5)
unique_data_outbrain_AN04A001 <- ans_conn_outbrain %>% filter(manc_type == "AN04A001")
unique_data_outbrain_AN04A001 <- unique_data_outbrain_AN04A001[order(unique_data_outbrain_AN04A001$weight, decreasing = T),] %>% slice_head(n=5)
  
  
unique_colours <- c("darkgreen", "orange")
colour_indices <- match(unique_data$pt_class, unique(unique_data$pt_class))
colour_indices_outbrain_AN07B005 <- match(unique_data_outbrain_AN07B005$pt_class, unique(unique_data_outbrain_AN07B005$pt_class))
colour_indices_outbrain_AN04A001 <- match(unique_data_outbrain_AN04A001$pt_class, unique(unique_data_outbrain_AN04A001$pt_class))


meshes_outbrain_AN07B005 <- read_mcns_meshes(unique_data_outbrain_AN07B005$partner, units = "nm")
meshes_outbrain_AN04A001 <- read_mcns_meshes(unique_data_outbrain_AN04A001$partner, units = "nm")

plot3d(meshes_outbrain_AN07B005, col = unique_colours[colour_indices_outbrain_AN07B005])
plot3d(meshes_outbrain_AN04A001, col = unique_colours[colour_indices_outbrain_AN04A001])

manc_view3d('ventral')
plot3d(malecns::malecns.surf, col = "gray", alpha = 0.1)
plot3d(malecns::malecnsvnc_shell.surf, col = "gray", alpha = 0.1)


#MANCsym.surf=symmetric_manc(MANC.surf, mirror=F)


plot3d(MANCsym.surf, col="gray", alpha =0.1)

rgl.snapshot(filename = "outbrain_AN04001_top5.png")




## totals by partner type
Tot up by pt_typej. Lots of DNs at top ones.
```{r}
topconns <- ans_conn_outbrain %>% 
  group_by(pt_typej, pt_class) %>% 
  count(wt = ROIweight, name = "ROIweight") %>% 
  arrange(desc(ROIweight))
```
Get the ones without a validated manc match: these need to be reviewed and assessed if the manc match is correct.
```{r}
ans_conn_outbrain %>% 
  filter(is.na(pt_typej)) %>% 
  filter(!is.na(pt_manc_bodyid) & is.na(pt_manc_group))
```
# Get synapse location
For plot of location of syanpses per class in GNG: is there any difference in areas?
  ```{r}
syn_conn_out_brain = neuprint_get_synapses(bodyids = my_ids, roi = "GNG",
                                           conn = mcns_neuprint())

syn_see <- select(syn_conn_out_brain, x, y, z, prepost)
synsee2 <- select(syn_conn_out_brain, x, y, z, bodyid, prepost) 
synsee2_out <- filter(synsee2, synsee2$prepost == 0)
synsee2_out$type <- ans_conn_outbrain[match(synsee2_out$bodyid, ans_conn_outbrain$bodyid),]$manc_type
synsee2_out$colours <- ifelse(synsee2_out$type =="AN07B005", "red", "blue")

mesh <- neuprintr::neuprint_ROI_mesh("GNG", dataset = 'cns')
prepostColours <- c("turquoise2", "magenta")
plot3d(mesh, type = "shade", col = "gray", alpha = 0.1, axes = F, box = F, xlab = "", ylab = "", zlab = "")
indices <- as.integer(as.array(syn_see$prepost)) + 1
points3d(syn_see, col = prepostColours[indices], size = .75)
points3d(synsee2_out, col = synsee2_out$colours)
manc_view3d('ventral', extramat = rotationMatrix(pi, 0,1,0))

rgl.snapshot(filename = "gng_syn_see_ANsorted.png")


ss <- "https://docs.google.com/spreadsheets/d/1HWZknKnmXpqKnCXTA-ozLL_d7LYMK4eYj1T02lnfwRc/edit?usp=sharing"
data_f <- googlesheets4::read_sheet(ss, sheet = "Sheet1")
data_AN04A001 <- filter(data_f, data_f$manc_type == "AN04A001")
data_AN07B005 <- filter(data_f, data_f$manc_type == "AN07B005")

manc_AN04A001_meshes <-read_manc_meshes(data_AN04A001$bodyid)
manc_AN07B005_meshes <-read_manc_meshes(data_AN07B005$bodyid)
mcns_AN04A001_meshes <-read_mcns_meshes(data_AN04A001$mcns_id)
mcns_AN07B005_meshes <-read_mcns_meshes(data_AN07B005$mcns_id)

manc_ids <- c(11260,	10823,	12834,	20216,	10516,	10925,	10295,	10426,	10540,	10687,	10418,	10443)
manc_AN04A001<-c(11260,	10823,	12834,	20216,	10516,	10925)
mcns_ids <- c(93227,	82880,	78114,	98764,	46240,	66800,	31227,	41101,	800658,	37217,	26680,	26278)
read_manc_meshes(manc_ids, units = "microns") -> manc_mesh
read_mcns_meshes(mcns_ids, units = "nm") -> mcns_mesh

mcns_ids_me <- c(26278, 26680)
read_mcns_meshes(mcns_ids_me, units = "nm") -> mcns_mesh_me
plot3d(mcns_mesh_me, col = "red")
plot3d(malecns::malecns.surf, col = "gray", alpha = 0.1)
plot3d(malecns::malecnsvnc_shell.surf, col = "gray", alpha = 0.1)

manc_ids_me <- c(10418,)
read_manc_meshes(manc_ids_me, units = "microns") -> manc_mesh_me
plot3d(manc_mesh_me, col = "red")
plot3d(malecns::malecns.surf, col = "gray", alpha = 0.1)
plot3d(malecns::malecnsvnc_shell.surf, col = "gray", alpha = 0.1)

rgl.snapshot(filename = "41-66800, 93227.png")


Sys.setenv(PATH = paste("/Users/ilinamoitra/Documents/opt/local/bin", Sys.getenv("PATH"), sep = ":"))

plot3d(mcns_mesh_2, col ="blue")
plot3d(manc_mesh_sym_AN07B005, col ="red")
plot3d(malevnc::MANC.tissue.surf.sym, col = "gray", alpha = 0.1)
manc_view3d('ventral')

manc_mesh_sym_AN04A001 <- symmetric_manc(manc_AN04A001_meshes * 0.001)
manc_mesh_sym_AN07B005 <- symmetric_manc(manc_AN07B005_meshes * 0.001)

plot3d(manc_mesh_sym_AN04A001, col ="blue")
plot3d(manc_mesh_sym_AN07B005, col ="red")
plot3d(malevnc::MANC.tissue.surf.sym, col = "gray", alpha = 0.1)
manc_view3d('ventral')

plot3d(FAFB14.surf)
clear3d()
library(nat)


plot3d(mcns_AN04A001_meshes, col ="blue")
plot3d(mcns_AN07B005_meshes, col ="red")

plot3d(malecns::malecns.surf, col = "gray", alpha = 0.1)
plot3d(malecns::malecnsvnc_shell.surf, col = "gray", alpha = 0.1)
manc_view3d('ventral', extramat = rotationMatrix(pi, 0,1,0))


rgl.snapshot(filename = "41-82880and98764.png")


plot3d(fancr::FANC.surf)


plot3d(MANC.tissue.surf)
if (!requireNamespace("remotes")) install.packages("remotes")
remotes::install_github('natverse/nat.jrcbrains')
library(nat.jrcbrains)
nat.jrcbrains::register_saalfeldlab_registrations()

library(nat.templatebrains)
plot(bridging_graph(), vertex.size=15)

mesh_manc_fafb <- xform_brain(manc_mesh, sample = "MANC", reference = FAFB14, via = "JRCFIB2018F")
mesh_mcns_fafb <- xform_brain(mcns_mesh, sample = "malecns", reference = FAFB14)

#Trying plotting skels
syn_skl <- neuprint_read_skeletons(11260,dataset = 'cns')
plot3d(syn_skl)

```
Threshold the confidence at more than 0.4.
Filter to partner bodyids from initial connectivity table.
Left_join from mcns annotations to add class.
# Inputs in the VNC
```{r}
ans_conn_invnc <- ans_conn %>% 
  filter(roi == "vnc-shell") %>% 
  filter(prepost == 1)
```
Any without a class
```{r}
see <- ans_conn_invnc %>% 
  filter(is.na(pt_manc_group))
```
see[order(see$bodyid, see$weight, decreasing = T),] ->display
display %>% group_by(bodyid) %>% slice_head(n=10) -> display10


#Heatmap

heatmap_matrix <- dcast(ans_conn_outbrain_top, partner ~ bodyid, value.var = "weight", fun.aggregate = sum)
rownames(heatmap_matrix) <- heatmap_matrix$partner
heatmap_matrix <- select(heatmap_matrix, -1)
Heatmap(heatmap_matrix)

ans_conn_outbrain_top <- ans_conn_outbrain_top[order(ans_conn_outbrain_top$pt_class),]

heatmap_matrix <- neuprint_get_adjacency_matrix(inputids = ans_conn_outbrain_top$partner, outputids = ans_conn_outbrain_top$bodyid, dataset = "cns")
Heatmap(heatmap_matrix)



#Network Diagrams
if(!"RCy3" %in% installed.packages()){
  install.packages("BiocManager")
  BiocManager::install("RCy3")
}
library(igraph)
class_data<-mcns_body_annotations(anc_conn_outbrain_filtered$bodyid)
df <- anc_conn_outbrain_filtered %>% select(bodyid, partner, weight)
df_reversed <- df %>% dplyr::rename(bodyid = partner, partner = bodyid)
df_combined <- data.table::rbindlist(list(df, df_reversed), fill = TRUE)

adj_matrix <- dcast(df_combined, bodyid ~ partner, value.var = "weight", fun.aggregate = sum)


all_ids <- as.integer(ans_conn_outbrain_top$partner)
all_ids <- unique(c(all_ids, my_ids))

all_ids_invnc <- as.integer(ans_conn_invnc_top$partner)
all_ids_invnc <- unique(c(all_ids_invnc, my_ids))

all_ids_outvnc <- as.integer(ans_conn_outvnc_top$partner)
all_ids_outvnc <- unique(c(all_ids_outvnc, my_ids))

type_data <- manc_dvid_annotations(ans_conn_outbrain_top$pt_manc_bodyid)
type_data$or_bodyid <- ans_conn_outbrain_top$bodyid
meta_ish_outbrain_cyto <- googlesheets4::read_sheet(ss, sheet = "add_type_outbrain")

adj_matrix <- neuprintr::neuprint_get_adjacency_matrix(all_ids, dataset = 'cns')
adj_matrix_invnc <- neuprintr::neuprint_get_adjacency_matrix(all_ids_invnc, dataset = "cns")
adj_matrix_outvnc <- neuprint_get_adjacency_matrix(all_ids_outvnc, dataset = "cns")


adj_matrix_invnc_df <- data.frame(
  row = rep(rownames(adj_matrix_invnc), each = ncol(adj_matrix_invnc)),
  col = rep(colnames(adj_matrix_invnc), times = nrow(adj_matrix_invnc)),
  value = c(adj_matrix_invnc)
)

id_type_df <- ans_conn_invnc_top %>% group_by(bodyid) %>% slice_head(n=1) %>% select(c(bodyid, manc_type))

merged_df <- merge(adj_matrix_invnc_df, id_type_df, by.x = "row", by.y = "bodyid", all.x = TRUE)
merged_df <- merge(merged_df, id_type_df, by.x = "col", by.y = "bodyid", all.x = TRUE, suffixes = c(".row", ".col"))

aggregated_df <- merged_df %>%
  group_by(manc_type.row, manc_type.col) %>%
  summarise(value = sum(value, na.rm = TRUE), .groups = "drop")

heatmap(adj_matrix_outvnc)
heatmap(adj_matrix_invnc)

np_adj_inv <- adj_matrix[match(my_ids,rownames(adj_matrix)),match(my_ids,colnames(adj_matrix))]

#names <- as.character(adj_matrix$bodyid)
#adj_matrix <- select(adj_matrix, -1)

#rownames(adj_matrix) <- names
#colnames(adj_matrix) <- names

#adj_matrix <- as.matrix(adj_matrix)

graph <- igraph::graph_from_adjacency_matrix(adj_matrix, weighted = T, diag = F)
graph_invnc <- igraph::graph_from_adjacency_matrix(adj_matrix_invnc, weighted = T, diag = F)
graph_outvnc <- igraph::graph_from_adjacency_matrix(adj_matrix_outvnc, weighted = T, diag = F)


V(graph)$class = as.character(mda$class[match(V(graph)$name, mda$bodyid)])
V(graph_invnc)$class = as.character(mda$class[match(V(graph_invnc)$name, mda$bodyid)])
V(graph_outvnc)$class = as.character(mda$class[match(V(graph_outvnc)$name, mda$bodyid)])

V(graph)$type = as.character(meta_ish_outbrain_cyto$pt_type[match(V(graph)$name, meta_ish_outbrain_cyto$partner)])


RCy3::createNetworkFromIgraph(graph_invnc)


type_data <- ans_conn_outbrain_top[match(all_ids, ans_conn_outbrain_top$partner),] %>% ungroup() %>% select(c("pt_type", "pt_manc_group"))
i = 1
for(i in i:length(type_data$pt_type))
{
  if(is.na(type_data$pt_type[i])){
      type_data$pt_type[i] <- mancanno[match(type_data$pt_manc_group[i], mancanno$group),]$type
    }
}

df_matrix <- as.data.frame(adj_matrix)
#df_matrix$type <- ans_conn_outbrain_top[match(all_ids, ans_conn_outbrain_top$partner),]$pt_type
df_matrix$type <- type_data$pt_type

i = 1
for (i in i:length(df_matrix$type)) {
  if(is.na(df_matrix$type[i])){
    df_matrix$type[i] <- all_ids[i]
  }
}

df_matrix2 <- df_matrix %>% replace_na(list(all_ids)) %>% group_by(type) %>% subset(select = -type )  %>% rowsum(df_matrix$type)


df_matrix <- as.data.frame(t(df_matrix2))

#df_matrix$type <- ans_conn_outbrain_top[match(all_ids, ans_conn_outbrain_top$partner),]$pt_type
df_matrix$type <- type_data$pt_type

i = 1
for (i in i:length(df_matrix$type)) {
  if(is.na(df_matrix$type[i])){
    df_matrix$type[i] <- all_ids[i]
  }
}

df_matrix2 <- df_matrix %>% replace_na(list(all_ids)) %>% group_by(type) %>% subset(select = -type )  %>% rowsum(df_matrix$type)

new_ids <- colnames(df_matrix2)




df_matrix <- as.data.frame(df_matrix2)
df_matrix$type <- ans_conn_outbrain_top[match(new_ids, ans_conn_outbrain_top$bodyid),]$manc_type
i = 1
for (i in i:length(df_matrix$type)) {
  if(is.na(df_matrix$type[i])){
    df_matrix$type[i] <- new_ids[i]
  }
}

df_matrix2 <- df_matrix %>% replace_na(list(new_ids)) %>% group_by(type) %>% subset(select = -type )  %>% rowsum(df_matrix$type)


df_matrix <- as.data.frame(t(df_matrix2))

df_matrix$type <- ans_conn_outbrain_top[match(new_ids, ans_conn_outbrain_top$bodyid),]$manc_type


i = 1
for (i in i:length(df_matrix$type)) {
  if(is.na(df_matrix$type[i])){
    df_matrix$type[i] <- new_ids[i]
  }
}

df_matrix2 <- df_matrix %>% replace_na(list(new_ids)) %>% group_by(type) %>% subset(select = -type )  %>% rowsum(df_matrix$type)




graph <- igraph::graph_from_adjacency_matrix(as.matrix(df_matrix2), weighted = T, diag = F)
RCy3::createNetworkFromIgraph(graph)


names <- as.data.frame(V(graph)$name)
new_data <- names
V(graph)$new_data <- new_data

#Plotting neurons in_vnc

anc_conn_invnc_filtered <- filter(ans_conn_invnc, weight >= 80)
unique_data <- anc_conn_invnc_filtered %>% group_by(partner) %>% slice_head(n=1)

unique_data_invnc_AN07B005 <- ans_conn_invnc %>% filter(manc_type == "AN07B005")
unique_data_invnc_AN07B005 <- unique_data_invnc_AN07B005[order(unique_data_invnc_AN07B005$weight, decreasing = T),] %>% slice_head(n=5)
unique_data_invnc_AN04A001 <- ans_conn_invnc %>% filter(manc_type == "AN04A001")
unique_data_invnc_AN04A001 <- unique_data_invnc_AN04A001[order(unique_data_invnc_AN04A001$weight, decreasing = T),] %>% slice_head(n=5)


unique_colours <- rainbow(length(unique(unique_data$pt_class)))
colour_indices <- match(unique_data$pt_class, unique(unique_data$pt_class))
colour_indices_invnc_AN07B005 <- match(unique_data_invnc_AN07B005$pt_class, unique(unique_data_invnc_AN07B005$pt_class))
colour_indices_invnc_AN04A001 <- match(unique_data_invnc_AN04A001$pt_class, unique(unique_data_invnc_AN04A001$pt_class))

manc_view3d('ventral')
meshes = read_mcns_meshes(unique_data$partner, units = "nm")
meshes_invnc_AN07B005 <- read_mcns_meshes(unique_data_outbrain_AN07B005$partner, units = "nm")
meshes_invnc_AN04A001 <- read_mcns_meshes(unique_data_outbrain_AN04A001$partner, units = "nm")

plot3d(meshes, col = unique_colours[colour_indices])
plot3d(meshes_invnc_AN07B005, col = unique_colours[colour_indices_invnc_AN07B005])
plot3d(meshes_invnc_AN04A001, col = unique_colours[colour_indices_invnc_AN04A001])

plot3d(malecns::malecns.surf, col = "gray", alpha = 0.1)
plot3d(malecns::malecnsvnc_shell.surf, col = "gray", alpha = 0.1)


#MANCsym.surf=symmetric_manc(MANC.surf, mirror=F)


plot3d(MANCsym.surf, col="gray", alpha =0.1)

rgl.snapshot(filename = "invnc_AN07B005_top5.png")

#Plotting neurons out_vnc

anc_conn_outvnc_filtered <- filter(ans_conn_outvnc, weight >= 20)
unique_data <- anc_conn_outvnc_filtered %>% group_by(partner) %>% slice_head(n=1)

unique_data_outvnc_AN07B005 <- ans_conn_outvnc %>% filter(manc_type == "AN07B005")
unique_data_outvnc_AN07B005 <- unique_data_outvnc_AN07B005[order(unique_data_outvnc_AN07B005$weight, decreasing = T),] %>% slice_head(n=5)
unique_data_outvnc_AN04A001 <- ans_conn_outvnc %>% filter(manc_type == "AN04A001")
unique_data_outvnc_AN04A001 <- unique_data_outvnc_AN04A001[order(unique_data_outvnc_AN04A001$weight, decreasing = T),] %>% slice_head(n=5)


unique_colours <- rainbow(length(unique(unique_data$pt_class)))
colour_indices <- match(unique_data$pt_class, unique(unique_data$pt_class))
colour_indices_outvnc_AN07B005 <- match(unique_data_outvnc_AN07B005$pt_class, unique(unique_data_outvnc_AN07B005$pt_class))
colour_indices_outvnc_AN04A001 <- match(unique_data_outvnc_AN04A001$pt_class, unique(unique_data_outvnc_AN04A001$pt_class))

manc_view3d('ventral')
meshes = read_mcns_meshes(unique_data$partner, units = "nm")
meshes_outvnc_AN07B005 <- read_mcns_meshes(unique_data_outvnc_AN07B005$partner, units = "nm")
meshes_outvnc_AN04A001 <- read_mcns_meshes(unique_data_outvnc_AN04A001$partner, units = "nm")
meshes = read_mcns_meshes(unique_data$partner, units = "nm")
plot3d(meshes, col = unique_colours[colour_indices])
plot3d(meshes_outvnc_AN07B005, col = unique_colours[colour_indices_invnc_AN07B005])
plot3d(meshes_outvnc_AN04A001, col = unique_colours[colour_indices_invnc_AN04A001])

plot3d(malecns::malecns.surf, col = "gray", alpha = 0.1)
plot3d(malecns::malecnsvnc_shell.surf, col = "gray", alpha = 0.1)


#MANCsym.surf=symmetric_manc(MANC.surf, mirror=F)


plot3d(MANCsym.surf, col="gray", alpha =0.1)

rgl.snapshot(filename = "outvnc_AN07B005_top5.png")


#Heatmap - Input

ans_conn_invnc_top <- ans_conn_invnc[order(ans_conn_invnc$bodyid, ans_conn_invnc$weight, decreasing = T),] %>% group_by(bodyid) %>% slice_head(n=3)
ans_conn_invnc_top <- ans_conn_invnc[order(ans_conn_outvnc$bodyid, ans_conn_invnc$weight, decreasing = T),] %>% group_by(bodyid) %>% slice_head(n=3)


ans_conn_invnc_top_unique <- group_by(ans_conn_invnc_top, partner) %>% slice_head(n=1)
#ans_conn_outvnc_top_unique$pt_class[ans_conn_outvnc_top_unique$pt_class == 'vnc_tbc'] <- 'intrinsic_neuron'
ans_conn_invnc_top_unique <- ans_conn_invnc_top_unique[order(ans_conn_invnc_top_unique$pt_class),]
ans_conn_invnc_top_unique_bodyid <- group_by(ans_conn_invnc_top, bodyid) %>% slice_head(n=1)
ans_conn_invnc_top_unique_bodyid <- ans_conn_invnc_top_unique_bodyid[order(ans_conn_invnc_top_unique_bodyid$manc_type),]

heatmap_matrix <- neuprintr::neuprint_get_adjacency_matrix(inputids = ans_conn_invnc_top_unique$partner, outputids = ans_conn_invnc_top_unique_bodyid$bodyid, dataset = "cns")

target_data_invnc <- my_ids_target[match(ans_conn_invnc_top_unique$pt_manc_bodyid, my_ids_target$partner),]$target

row_anno <- ComplexHeatmap::rowAnnotation(Class = ans_conn_invnc_top_unique$pt_class, Target = target_data_invnc, col = tmp2)
col_anno <- ComplexHeatmap::HeatmapAnnotation(Type = ans_conn_invnc_top_unique_bodyid$manc_type, col = tmp)
col_fun = colorRamp2(c(0, max(heatmap_matrix)), c("darkblue", "yellow"))

unique_class <- unique(ans_conn_invnc_top_unique$pt_class)
colours_class <- RColorBrewer::brewer.pal(n= length(unique_class), name = "Dark2")
tmp = as.data.frame(colours_class)
rownames(tmp) <- unique_class
tmp<-list(tmp$colours_class)

tmp <-list(Type = c("AN04A001" = "blue", "AN07B005" = "red"))
tmp2 <-list(Class = c("ascending_neuron" = colours_class[1], "intrinsic_neuron" = colours_class[2], "motor" = colours_class[3])) 

ComplexHeatmap::Heatmap(heatmap_matrix, name = "Weight", right_annotation = row_anno, top_annotation = col_anno, col = col_fun, column_names_side = 'top', cluster_rows = FALSE, cluster_columns = F)


#Heatmap - Output

ans_conn_outvnc_top <- ans_conn_outvnc[order(ans_conn_outvnc$bodyid, ans_conn_outvnc$weight, decreasing = T),] %>% group_by(bodyid) %>% slice_head(n=3)

ans_conn_outvnc_top_unique <- group_by(ans_conn_outvnc_top, partner) %>% slice_head(n=1)

ans_conn_outvnc_top_unique$pt_class[ans_conn_outvnc_top_unique$pt_class == 'vnc_tbc'] <- 'undefined_vnc_neuron'

ans_conn_outvnc_top_unique <- ans_conn_outvnc_top_unique[order(ans_conn_outvnc_top_unique$pt_class),]
ans_conn_outvnc_top_unique_bodyid <- group_by(ans_conn_outvnc_top, bodyid) %>% slice_head(n=1)
ans_conn_outvnc_top_unique_bodyid <- ans_conn_outvnc_top_unique_bodyid[order(ans_conn_outvnc_top_unique_bodyid$manc_type),]

heatmap_matrix <- neuprintr::neuprint_get_adjacency_matrix(inputids = ans_conn_outvnc_top_unique$partner, outputids = ans_conn_outvnc_top_unique_bodyid$bodyid, dataset = "cns")

origin_data_outvnc <- my_ids_target[match(ans_conn_outvnc_top_unique$pt_manc_bodyid, my_ids_target$partner),]$origin

tmp <-list(Type = c("AN04A001" = "blue", "AN07B005" = "red"))
tmp2 <-list(Class = c("ascending_neuron" = colours_class[1], "intrinsic_neuron" = colours_class[2], "descending_neuron" = colours_class[3], "undefined_vnc_neuron" = colours_class[4]))

row_anno <- ComplexHeatmap::rowAnnotation(Class = ans_conn_outvnc_top_unique$pt_class, Origin = origin_data_outvnc, col = tmp2)
col_anno <- ComplexHeatmap::HeatmapAnnotation(Type = ans_conn_outvnc_top_unique_bodyid$manc_type, col = tmp)
col_fun = colorRamp2(c(0, max(heatmap_matrix)), c("darkblue", "yellow"))

unique_class <- unique(ans_conn_outvnc_top_unique$pt_class)
colours_class <- RColorBrewer::brewer.pal(n= length(unique_class), name = "Dark2")
tmp = as.data.frame(colours_class)
rownames(tmp) <- unique_class
tmp<-list(tmp$colours_class)

ComplexHeatmap::Heatmap(heatmap_matrix, name = "Weight", right_annotation = row_anno, top_annotation = col_anno, col = col_fun, column_names_side = 'top', cluster_rows = FALSE, cluster_columns = F)



