#Clustering DA2 downstream partners by morphology
#Compare initial 10% downstream sample to complete connectome

initial = catmaid_skids("FML - downstream of first DA2")
all = catmaid_skids("FML - downstream of DA2")

#Fetches all skids with the same annotation
#"FML downstream of first DA2" is all skids found in first sample, whilst "FML downstream of DA2" is all skids downstream of DA2, including initial sample

new = all[!all%in%initial]

#Subtracts initial skids from all skids, giving all skids not represented in the initial sample
#initial + new = all

initial_dp = fetchdp_fafb(initial)
new_dp = fetchdp_fafb(new)

#Fetches dot-props (NBLAST) for each skid

all_dp = c(initial_dp, new_dp)

#May seem like a step backwards, but it is important to distinguish between initial and new when it comes to colouring the leafs of the dendrogram later

DA2_matrix = nblast_allbyall(all_dp)

#NBLASTs each neurone against every other in dot-prop format, returning an "interaction matrix"

DA2_matrix_clustered = nhclust(score = DA2_matrix)

#Carries out heirarchical clustering of DA2_matrix

plot(DA2_matrix_clustered, main = 'whole neurone morphology')

#Plots a dendrogram clustering neurones by morphology

#From here there are a few options to manipulate the graph

#Option 1: Colour branches by height (h=6)

plot(colour_clusters(DA2_matrix_clustered, h = 6, col = rainbow))

#Option 2: #Sets leaf edges to any specified colour
plot(set_leaf_colours(as.dendrogram(DA2_matrix_clustered), "red", col_to_set = c("edge")))

#The function set_leaf_colours() requires you to specify that DA2_matrix_clustered is a dendrogram, for which we use as.dendrogram()

#Option 3: Colour leafs by whether they come from the initial or new samples (from Nik Drummond)

