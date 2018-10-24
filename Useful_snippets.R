##### Useful snippets #####

##### if else shortcut ####
#instead of doing:
for (i in Bool) {     #Bool being a logical vector
  if(i) {
    colour = c(colour, 'red')
  } else {
    colour = c(colour, 'blue')
  }
}
#this way is much quicker:
if else(Bool, "red", "blue")

##### naming character vectors ####
list("name1" = "character1", "name2" = "character2")

#### table function to build a contingency table of 
#the counts at each combination of factor levels. ####
connectivity_matrix <- catmaid_get_connectors_between(pre_skids = catmaid_skids("annotation:NAMK_DANs_all"), 
                                                      post_skids = 1159799)
table(connectivity_matrix$pre_skid) #counts the number of times each pre_skid occurs in the df, ie. number of synapses from pre_skid to post_skid