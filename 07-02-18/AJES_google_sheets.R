#Extracting and updating data from and to googlesheets in R
library(googlesheets)
gs_ls()

#read google sheets
y5 <- gs_title("Upstream SMP (PAM-y5)")

#Problem solve:
gs_read(ss = y5, ws = 5, range = "B52:B73")
as.list(gs_read(ss = y5, ws = 4, range = "B52:B73"))
skids<-as.list(gs_read(ss = y5, ws = 7, range = "A2:A90"), col_names = FALSE, skip = 1)[[1]]
skids <- skids[-1]
library(elmr)
results <- lapply(c(1:length(skids)), function(x) nblast_fafb(skids[[x]])) #Takes a long time, probably not recomended!
df <- lapply(c(1:length(skids)), function(x) summary(results[[x]]))
names(df) <- lapply(c(1:length(skids)), function(x) catmaid_get_neuronnames(skids[[x]]))
index <- which(names(df)=="neuron 3336471 JJ- FW-B6")

#Function that updates google sheet to add info about already connected neurons
neuron_names <- as.vector(catmaid_get_neuronnames(skids))
#gs_edit_cells(y5, ws = 7, input = neuron_names, anchor = "K4", byrow = FALSE)

PAM6 <- catmaid_get_neuronnames("annotation:SMP_upstream_PAM6")
PAM7 <- catmaid_get_neuronnames("annotation:SMP_upstream_PAM7")
PAM13 <- catmaid_get_neuronnames("annotation:SMP_upstream_PAM13")
PAM5<- catmaid_get_neuronnames("annotation:SMP upstream of Ringling Brothers")
PAM17 <- catmaid_get_neuronnames("annotation:SMP_upstream_PAM17")
y5_upstream <- c(PAM6, PAM7, PAM13, PAM5, PAM17)
y5_all <-y5_upstream[!duplicated(y5_upstream)]
skids <- as.numeric(names(y5_all))
names <- catmaid_get_neuronnames(skids)

x <- lapply(c(1:length(skids)), function (x) catmaid_get_annotations_for_skeletons(skids[x])$annotation[grep(as.character("AJES_y5_sampled"),catmaid_get_annotations_for_skeletons(skids[x])$annotation)])
x[lengths(x) == 0] <- ""
df <- data.frame("annotation_lin"= unlist(x), names, skids)
gs_edit_cells(y5, ws = 7, input = names, anchor = "B2", byrow = FALSE)
x
annotation_list <- catmaid_get_annotations_for_skeletons(skids[1])$annotation
annotation_list[grep(as.character("AJES_y5_sampled"),annotation_list)]




catmaid_skids("annotation:SMP_upstream_PAM1$") %in% unique(skids)

