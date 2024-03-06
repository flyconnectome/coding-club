#### Connectivity heat-maps ####

pre <- unique(c(catmaid_skids("annotation:^SMP_upstream_PAM6$"),
                catmaid_skids("annotation:^SMP_upstream_PAM7$"),
                catmaid_skids("annotation:^SMP_upstream_PAM13$"),
                catmaid_skids("annotation:^SMP upstream of Ringling Brothers$")
                
))
#Remove M6 from all upstream
pre <- pre[-which(pre == 2109445)]
post <- c(3643424, 5234721,3026119,5952626)

#Returns df with no. of synapses from given pre_skids (row names) to given post_skids (col names)
conn_table <- function(pre, post){
  library(catmaid)
  #Get all connectors between given pre and post skids
  total_conn_table <-catmaid_get_connectors_between(post_skids = post, pre_skids = pre)
  #Get the range of indices of pre and post skids to pass into lapply function
  post_range <- c(1:length(post))
  pre_range <- c(1:length(pre))
  
  conn_table_count <- data.frame(pre)
  #Go through each pre and post skid in the connectivity table and count the synapses between the same pre and post skids
  for(i in post_range){
    x <- lapply(pre_range, function(x) length(which(which(total_conn_table$pre_skid %in% pre[x] == TRUE)
                                                    %in% which(total_conn_table$post_skid %in% post[i] == TRUE))))
    df <- t(as.data.frame(x))
    conn_table_count <- cbind(conn_table_count, df)
  }
  conn_table_count <- conn_table_count[,-1]
  col.names <- catmaid_get_neuronnames(post)
  row.names <- catmaid_get_neuronnames(pre)
  colnames(conn_table_count) <- col.names
  rownames(conn_table_count) <- row.names
  conn_table_count <- as.matrix(conn_table_count)
}

connectivity_matrix <- conn_table(pre = pre, post = post)

##### Heat Maps ####
col_names <- c("(5) RB","(6) CB", "(7)", "(13)")
gplots::heatmap.2(connectivity_matrix, srtCol = 0,
                  #col = colorRampPalette(c("navy", "cyan", "yellow", "red3")),
                  notecex = 0.7, 
                  keysize = 0.9, 
                  cexCol = 1, 
                  cexRow = 0.3, 
                  margins = c(3,10),
                  density.info = "none",
                  trace = "none",
                  dendrogram = "row",
                  key.title = "Synapse number",
                  key.xlab = "Synapse number",
                  labCol = col_names,
                  breaks = c(seq(0, 0.4, length = 100), #enable colour transitation at specified limits
                             seq(0.5, 2, length = 100), #for cyan
                             seq(2.1, 3.4, length = 100), #for yellow
                             seq(3.5, max(con_tab), length = 100))) 

