#Update googlesheet with neurons that are already connected
library(googlesheets)
gs_ls()
y5 <- gs_title("Upstream SMP (PAM-y5)")
con_id <- as.list(gs_read(ss = y5, ws = 3, range = "C2:C90"))[[1]][-1]#change the range to the region that you want to update (ie. DO NOT INCLUDE THE RANGE YOU HAVE ALREADY SAMPLED)
post_skid <- gs_read(ss = y5, ws = 3, range = "B4:B5")[[1]]

#find final skid and final neuron name
con_tab <- catmaid_get_connectors(con_id) #get df of conn_id, pre and post skids
post_con_tab <- con_tab[con_tab$post %in% post_skid,] #subset so only your post skid of interest, 
#debug: 
nrow(post_con_tab) == length(con_id) #should be TRUE
sort_con_tab <- post_con_tab[unlist(lapply(1:nrow(post_con_tab), function(x) which(post_con_tab$connector_id %in% con_id[[x]]))),] #sort so conn id is same order as googlesheet

final_skid <- sort_con_tab$pre
final_name <- catmaid_get_neuronnames(final_skid)
final_name[which(!nchar(unname(final_name))>14)] <- "" #remove any names less than 14 characters as these are usually fragments
final_skid[which(!nchar(unname(final_name))>14)] <- "" #remove the skids of those fragments


#use gs_edit_cells to update final neuron name and final skid. 
#NB/ BE VERY CAREFUL WITH WHAT YOU CHOOSE FOR THE ANCHOR ARGUMENT AS THIS FUNCTION OVERWRITES ANYTHING ALREADY IN THE GOOGLESHEET
?gs_edit_cells  #anchor: single character string specifying the upper left cell of the cell range to edit; positioning notation can be either "A1" or "R1C1"
#gs_edit_cells(ss= ss, ws = ws, anchor = "Kx", input = final_name)
#gs_edit_cells(ss= ss, ws = ws, anchor = "Lx", input = final_skid)
