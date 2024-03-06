#### Returns df with no. of synapses from given pre_skids (row names) to given post_skids (col names), ####
#### can filter by total no. of synapses to all post-synaptic neurons (syn_no_threshold)               ####
conn_table <- function(pre, post, syn_no_threshold = NA){
  library(catmaid)
  con_tab <- catmaid_get_connectors_between(pre_skids = pre, post_skids = post)
  if(is.na(syn_no_threshold)){
    pre_new <- pre
    con_tab_new <- con_tab
  }else if(!is.na(syn_no_threshold)){
  #order pre-synaptic skids by total no. of synapses to post-syn neurons
  syn_no <- sort(table(con_tab$pre_skid), decreasing = T) 
  #return skids of pre-synaptic neurons which have more than the syn_no_threshold no. of inputs to post-syn neurons
  pre_new <- as.numeric(names(syn_no[syn_no > syn_no_threshold]))
  #subset con_tab to only contain pre_new skids
  con_tab_new <- con_tab[con_tab$pre_skid %in% pre_new,]
  }
  #make an empty dataframe of NA to put number of synapses from pre_new to post
  conn_table_count <- as.data.frame(matrix(NA, nrow = length(pre_new), ncol = length(post)))
  count_func <- function(x){
  #For each post_synaptic neuron give number of inputs from pre_skids
  post_specific_con_tab <- as.data.frame(table(con_tab_new[con_tab_new$post_skid %in% post[x],]$pre_skid))
  #reorder post_specific_con_tab to the order of pre_new
  order_new <- pre_new[pre_new %in% post_specific_con_tab$Var1]
  order_index <- sapply(1:length(order_new), function(x) which(post_specific_con_tab$Var1 %in% order_new[[x]]))
  post_specific_con_tab <- post_specific_con_tab[order_index,]
  post_specific_con_tab
  #conn_table_count is in order of pre_new and will contain all pre_new skids, 
  #add number of synapses from pre_new to specific post-skid
  conn_table_count[which(pre_new %in% post_specific_con_tab$Var1),x] <<- post_specific_con_tab$Freq
  conn_table_count[which(!pre_new %in% post_specific_con_tab$Var1),x] <<- 0
  }
  lapply(1:length(post), count_func)
  colnames(conn_table_count) <- catmaid_get_neuronnames(post)
  rownames(conn_table_count) <- paste(pre_new, catmaid_get_neuronnames(pre_new), sep = "--")
  library(dplyr)
  #reorder conn_table_count by synapse no to post-syn neurons
  conn_table_count <- conn_table_count[names(sort(rowSums(conn_table_count), decreasing = T)),]
  conn_table_count <- as.matrix(conn_table_count)
  return(conn_table_count)
}

#### Plotting connectivity table as a heatmap ####
#takes a matrix connectivity table (as made using "conn_table" function.)
#range must be a list of numbers to define the range for discrete colours in heatmap, eg.:
range <- list(0, 1:2, 3:5, 6:10, 11:(max(con_tab)))
#dis_col is a vector of colours you want for the different ranges, eg.:
dis_col <- c("gray88", colorRampPalette(c("yellow", "steelblue4"))(length(range)-1))
length(range) == length(dis_col) #must be TRUE
#col_nemaes is a character vector for the names of post-synaptic neurons
col_names <- c("y5-(1)","y5-(5)","y5-(6)","y5-(7)","y5-(10)", "y5-(13)","y5-(17)",
               "B'2a-(1)","B'2a-(2)","B'2a-(4)",
               "MP1")
heatmap_discrete_col <- function(con_tab, range, dis_col, col_names){
  #labels for the legend describing the range of synapses in each bin
  labels <-c("0", sapply(2:length(range), function(x) paste(min(range[[x]]), max(range[[x]]), sep = "-")))
  #because of the way the heatmap function works a vector of colours must be made to specify the colour for each synapse no.
  #therefore colours must be repeated if they are in the same range
  col <- unlist(sapply(1:length(range), function(x) rep(dis_col[x], length(range[[x]]))))
  #sets margins for plot
  par(mar = c(5,5,5,5))
  gplots::heatmap.2(con_tab, 
                    srtCol = 0,
                    col = col,
                    notecex = 0.7, 
                    keysize = 0.75, 
                    cexCol = 1, 
                    cexRow = 0.5, 
                    margins = c(3,10),
                    density.info = "none",
                    key = FALSE,
                    trace = "none",
                    dendrogram = "none",
                    labCol = col_names,
                    Rowv = FALSE,
                    Colv = FALSE)
  #plot.new()
  #par(mar = c(1,1,1,1))
  par(xpd = T)
  legend(-0.16,0.97,
         labels,
         fill = dis_col,
         cex = 1,
         title = "Number of synapses")
}
########################################################################
all <- catmaid_skids("annotation:NAMK_DANs_all")
y5s <- c(3639761, 3643424, 5234721, 3026119, 5652208, 5952626,6059582)
b2as <- c(7777207, 7270967, 8317886)
MP1s <- 1159799
dans <- c(y5s, b2as, MP1s)
con_tab <- conn_table(pre = all, post = dans, syn_no_threshold = 3)
########################################################################
col_names <- c("y5-(1)","y5-(5)","y5-(6)","y5-(7)","y5-(10)", "y5-(13)","y5-(17)",
               "B'2a-(1)","B'2a-(2)","B'2a-(4)",
               "MP1")
range <- list(0, 1:2, 3:5, 6:10, 11:(max(con_tab))) #define range for discrete colours
dis_col <- c("gray88", colorRampPalette(c("yellow", "steelblue4"))(length(range)-1)) #vector of discrete colors
length(range) == length(dis_col) #must be TRUE
heatmap_discrete_col(con_tab = con_tab, range = range, dis_col = dis_col, col_names = col_names)
########################################################################