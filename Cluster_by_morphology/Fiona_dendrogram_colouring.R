library(elmr)
library(dendroextras)

#get the skeleton IDs of all the neurons we want to look at
DA2ds = catmaid_skids("FML - downstream of DA2")

#read the neurons in as dotprops, NBLAST them all-by-all, cluster, and produce a dendrogram
da2ds.dps = fetchdp_fafb(DA2ds, mirror = FALSE)
da2ds.aba = nblast_allbyall(da2ds.dps)
da2ds.hclust = nhclust(da2ds.aba)
da2ds.dend = as.dendrogram(da2ds.hclust)

#distinguish which neurons belong to the initial sample and which are new
initial = catmaid_skids("annotation:^FML - downstream of first DA2$")
new = DA2ds[!DA2ds %in% initial]

#assign a colour for each population of neurons
colours = list("new" = "red", "initial" = "blue")

#there's a lot going on here, so I'll comment each line to explain it
da2ds.hclust.col = 
    sapply(                                      # we need to run this for each skeleton ID and get the result as a vector, hence sapply
      labels(da2ds.hclust),                      # this is what we're running the function over, our skids in the order given by the clustering
      function(s){                                
        if(s %in% initial){ colours$initial }    # if the skeleton ID is in the initial sample, give it the colour we assigned for 'initial'
        else if(s %in% new){ colours$new }       # if the skeleton ID is new, give it the colour we assigned for 'new'
        else{ "darkgray" }                       # all our skids should be in either new or initial, so nothing should get this far, but it will help spot anything that's gone wrong
        }
      )


names(da2ds.hclust.col) = labels(da2ds.hclust) #this isn't strictly necessary, but it gives the vector we made in the last step names so we can tell which skeleton ID corresponds to each value


dend.col = set_leaf_colors(da2ds.dend, col = da2ds.hclust.col) #colour each 'leaf' edge
dend.col = set_leaf_colors(dend.col, col = da2ds.hclust.col, col_to_set = "label") #colour the labels as well to make it clearer
dend.col = set_leaf_colors(dend.col, col = da2ds.hclust.col, col_to_set = "node") #setting the leaf colours automatically adds circular nodes to the end of each leaf, so colour those as well
par(cex = 0.2, cex.axis = 5) #Adjusting font sizes here (shrinking all the text, and then sizing up the axis labels to compensate).  The skeleton IDs are basically too small to read now, but this keeps them from overlapping and muddling the colors.  You could also just remove the labels, but this way you can still zoom in and identify a particular neuron if you want to.
plot(dend.col) #Plot our beautiful dendrogram

