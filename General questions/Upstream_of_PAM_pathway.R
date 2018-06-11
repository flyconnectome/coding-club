#Pathways upstream of y5-PAMs


#Look upstream of one PAM, then the 1st to 3rd or 4th order upstream of that. 
#Compare the list of these neurons with those upstream of other PAMs.
#Are any of these 2nd, 3rd, 4th order neurons MVP2?
library(catmaid)
annotation <- c("SMP_upstream_PAM1", "SMP_upstream_PAM10", "SMP_upstream_PAM13",
                "SMP_upstream_PAM17", "SMP_upstream_PAM6", "SMP_upstream_PAM7", "SMP upstream of Ringling Brothers")
upper_skids <- catmaid_skids("annotation:^GRN candidate$")
annotation <- "MWP_UPSTREAM_MP1"
upper_skids <- 2333007


upper_order_skids_func <- function(annotation){
  y5_PAM_upstream_skids <- catmaid_skids(paste0("annotation:^", annotation, "$", collapse = ""))
  first_order_skids <- unique(catmaid_get_connectors_between(post_skids = y5_PAM_upstream_skids)$pre_skid)
  second_order_skids <- unique(catmaid_get_connectors_between(post_skids = first_order_skids)$pre_skid)
  third_order_skids <- unique(catmaid_get_connectors_between(post_skids = second_order_skids)$pre_skid)
  list<- list(y5_PAM_upstream_skids, first_order_skids, second_order_skids, third_order_skids)
  names(list) <- c("y5_PAM_upstream", "first_order", "second_order", "third_order")
  return(list)
}
upstream_pathways <- lapply(1:length(annotation), function(x) upper_order_skids_func(annotation[x]))
names(upstream_pathways) <- annotation
#Compare the first, second and third order neurons for each PAM... are there any unique ones?
upstream_pathways[[1]]$first_order 

list <- upstream_pathways
unique_function <- function(list){
second_order <- lapply(1:length(list), function(x) list[[x]]$second_order)
names(second_order) <- annotation
#use setdiff to be left with the unique values
#then go through each list and ask which list contains the unique values and what they are
unique <- Reduce(setdiff, second_order)
unique_list <- lapply(1:length(second_order), function(x) second_order[[x]][second_order[[x]] %in% unique])
return(unique_list)
}
unique_function(list)

stream_function <- function(annotation_index, upper_skids){
y5_PAM_upstream_skids <- catmaid_skids(paste0("annotation:^", annotation[annotation_index], "$", collapse = ""))
first_order <- catmaid_get_connectors_between(post_skids = y5_PAM_upstream_skids)
second_order <- catmaid_get_connectors_between(post_skids = unique(first_order$pre_skid))
third_order <- catmaid_get_connectors_between(post_skids = unique(second_order$pre_skid))

third_order_skids <- unique(third_order$pre_skid[which(third_order$pre_skid %in% upper_skids)])
second_order_skids <- catmaid_skids(unique(third_order[third_order$pre_skid %in% upper_skids,]$post_skid))
first_order_skids <- catmaid_skids(unique(second_order[second_order$pre_skid %in% second_order_skids,]$post_skid))
y5_PAM_upstream_pathway_skids <- catmaid_skids(unique(first_order[first_order$pre_skid %in% first_order_skids,]$post_skid))

third_order_names <- catmaid_get_neuronnames(third_order_skids)
second_order_names <- catmaid_get_neuronnames(second_order_skids)
first_order_names <- catmaid_get_neuronnames(first_order_skids)
y5_PAM_upstream_pathway_names <- catmaid_get_neuronnames(y5_PAM_upstream_pathway_skids)
list_pathway <- list(y5_PAM_upstream_pathway_names, first_order_names, second_order_names, third_order_names)
names(list_pathway) <- c("y5_direct_upstream", "first_order", "second_order", "third_order")
return(list_pathway)
}
GRN_pathway <- lapply(c(1:length(annotation)), stream_function, upper_skids = upper_skids)
names(GRN_pathway) <- annotation
capture.output(GRN_pathway, file = "GRN_to_y5_PAM_pathways.csv")

MVP2_pathway <- lapply(1:length(annotation), stream_function, upper_skids = 2333007)
names(MVP2_pathway) <- annotation
capture.output(MVP2_pathway, file = "MVP2_to_y5_PAM_pathways.csv")

annotation_index <- 5
############################################################################################################################
############################################################################################################################
############################################################################################################################
############################################################################################################################
###############################Rerun stream function with fewer sandwich layers###################################
stream_function <- function(annotation_index, upper_skids){
  y5_PAM_upstream_skids <- catmaid_skids(paste0("annotation:^", annotation[annotation_index], "$", collapse = ""))
  #y5_PAM_upstream_skids <- y5_PAM_upstream_skids[!y5_PAM_upstream_skids %in% 2109445]
  #y5_PAM_upstream_skids <- y5_PAM_upstream_skids[!y5_PAM_upstream_skids %in% 3100730]
  first_order <- catmaid_get_connectors_between(post_skids = y5_PAM_upstream_skids)
  #first_order <- first_order[!first_order$pre_skid %in% 2109445,]
  #first_order <- first_order[!first_order$pre_skid %in% 3100730,]
  second_order <- catmaid_get_connectors_between(post_skids = unique(first_order$pre_skid))
  #second_order <- second_order[!second_order$pre_skid %in% 2109445,]
  #second_order <- second_order[!second_order$pre_skid %in% 3100730,]
  second_order_skids <- unique(second_order$pre_skid[which(second_order$pre_skid %in% upper_skids)])
    if(length(second_order_skids) == 0){
    list <- c(NA, NA, NA)
    names(list) <- c("y5_direct_upstream", "first_order", "second_order")
    return(list)
  }else{
  first_order_skids <- catmaid_skids(unique(second_order[second_order$pre_skid %in% second_order_skids,]$post_skid))
  y5_PAM_upstream_pathway_skids <- catmaid_skids(unique(first_order[first_order$pre_skid %in% first_order_skids,]$post_skid))
  second_order_names <- catmaid_get_neuronnames(second_order_skids)
  first_order_names <- catmaid_get_neuronnames(first_order_skids)
  y5_PAM_upstream_pathway_names <- catmaid_get_neuronnames(y5_PAM_upstream_pathway_skids)
  list_pathway <- list(y5_PAM_upstream_pathway_names, first_order_names, second_order_names)
  names(list_pathway) <- c("y5_direct_upstream", "first_order", "second_order")
  return(list_pathway)
  }
}
############################################################################################################################
############################################################################################################################
############################################################################################################################
GRN_pathway <- lapply(c(1:length(annotation)), stream_function, upper_skids = upper_skids)
names(GRN_pathway) <- annotation
capture.output(GRN_pathway, file = "GRN_to_y5_PAM_pathways_fewer_layers.csv")
GRN_to_PAM1_skids <- as.numeric(unlist(lapply(1:3, function(x) (names(GRN_pathway$SMP_upstream_PAM1[[x]])))))
GRN_to_PAM10_skids <- as.numeric(unlist(lapply(1:3, function(x) (names(GRN_pathway$SMP_upstream_PAM10[[x]])))))
GRN_to_PAM13_skids <- as.numeric(unlist(lapply(1:3, function(x) (names(GRN_pathway$SMP_upstream_PAM13[[x]])))))
GRN_to_PAM17_skids <- as.numeric(unlist(lapply(1:3, function(x) (names(GRN_pathway$SMP_upstream_PAM17[[x]])))))
GRN_to_PAM6_skids <- as.numeric(unlist(lapply(1:3, function(x) (names(GRN_pathway$SMP_upstream_PAM6[[x]])))))

MVP2_pathway <- lapply(c(1:length(annotation)), stream_function, upper_skids = upper_skids)
names(MVP2_pathway) <- annotation
MVP2_to_PAM1_skids <- as.numeric(unlist(lapply(1:3, function(x) (names(MVP2_pathway$SMP_upstream_PAM1[[x]])))))
MVP2_to_PAM10_skids <- as.numeric(unlist(lapply(1:3, function(x) (names(MVP2_pathway$SMP_upstream_PAM10[[x]])))))
MVP2_to_PAM13_skids <- as.numeric(unlist(lapply(1:3, function(x) (names(MVP2_pathway$SMP_upstream_PAM13[[x]])))))
MVP2_to_PAM17_skids <- as.numeric(unlist(lapply(1:3, function(x) (names(MVP2_pathway$SMP_upstream_PAM17[[x]])))))
MVP2_to_PAM6_skids <- as.numeric(unlist(lapply(1:3, function(x) (names(MVP2_pathway$SMP_upstream_PAM6[[x]])))))
MVP2_to_PAM7_skids <- as.numeric(unlist(lapply(1:3, function(x) (names(MVP2_pathway$SMP_upstream_PAM7[[x]])))))
MVP2_to_PAM5_skids <- as.numeric(unlist(lapply(1:3, function(x) (names(MVP2_pathway$SMP upstream of Ringling Brothers[[x]])))))
catmaid_set_annotations_for_skeletons(MVP2_to_PAM17_skids, "AJES_MVP2_to_y5PAM17", force = T)

#find neurons that are unique to each PAM within these streams
Reduce(setdiff, list(MVP2_to_PAM1_skids, MVP2_to_PAM10_skids, MVP2_to_PAM13_skids,
                     MVP2_to_PAM17_skids, MVP2_to_PAM6_skids, MVP2_to_PAM7_skids))

#GRNs to MP1
GRN_to_MP1 <- stream_function(1, upper_skids = upper_skids)
skids <- unlist(lapply(1:3, function(x) as.numeric(names(GRN_to_MP1[[x]]))))
#catmaid_set_annotations_for_skeletons(skids, "AJES_GRN_to_MP1")


#GRNs to Yeats
upper_skids <- catmaid_skids("annotation:^GRN candidate$")
annotation <-  "AJES_upstream_Yeats"
GRN_to_Yeats <- stream_function(1, upper_skids = upper_skids)
#returns NA NA NA which means GRNs are not upstream of Yeats 
