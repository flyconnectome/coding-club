#Extracting and updating data from and to googlesheets in R
library(googlesheets)
gs_ls()

#read google sheets
y5 <- gs_title("Upstream SMP (PAM-y5)")

#Problem solve:
gs_read(ss = y5, ws = 4, range = "B52:B73")
as.list(gs_read(ss = y5, ws = 4, range = "B52:B73"))
skids<- as.list(gs_read(ss = y5, ws = 4, range = "B52:B73"), col_names = FALSE)[[1]] #misses first one in list


library(elmr)
results <- lapply(c(1:length(skids)), function(x) nblast_fafb(skids[[x]])) #Takes a long time, probably not recomended!
df <- lapply(c(1:length(skids)), function(x) summary(results[[x]]))
names(df) <- lapply(c(1:length(skids)), function(x) catmaid_get_neuronnames(skids[[x]]))
index <- which(names(df)=="neuron 3336471 JJ- FW-B6")

#Function that updates google sheet to add info about already connected neurons
neuron_names <- as.vector(catmaid_get_neuronnames(skids))
#gs_edit_cells(y5, ws = 4, input = neuron_names, anchor = "M53", byrow = FALSE)


