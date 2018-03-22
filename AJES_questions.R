# R-club 21st March

#### Tidying up code ####
PAM6 <- catmaid_get_neuronnames("annotation:SMP_upstream_PAM6")
PAM7 <- catmaid_get_neuronnames("annotation:SMP_upstream_PAM7")
PAM13 <- catmaid_get_neuronnames("annotation:SMP_upstream_PAM13")
PAM5<- catmaid_get_neuronnames("annotation:SMP upstream of Ringling Brothers")
PAM17 <- catmaid_get_neuronnames("annotation:SMP_upstream_PAM17")
y5_upstream <- c(PAM6, PAM7, PAM13, PAM5, PAM17)
y5_all <-y5_upstream[!duplicated(y5_upstream)]
skids <- as.numeric(names(y5_all))
names <- unlist(lapply(1:length(y5_all), function(x) y5_upstream[[x]]))
#gs_edit_cells(y5, ws = 7, input = names, anchor = "B2", byrow = FALSE)

x <- lapply(c(1:length(skids)), function (x) catmaid_get_annotations_for_skeletons(skids[x])$annotation[grep(as.character("AJES_y5_sampled"),catmaid_get_annotations_for_skeletons(skids[x])$annotation)])
x[lengths(x) == 0] <- NA
y <- lapply(c(1:length(skids)), function (x) catmaid_get_annotations_for_skeletons(skids[x])$annotation[grep(as.character("AJES_y5_upstream"),catmaid_get_annotations_for_skeletons(skids[x])$annotation)])
y[lengths(y) == 0] <- NA
df <- data.frame("annotation_lin"= unlist(x), "annotation_neuropil"= unlist(y), names, skids)
