# Loading PAM DANs
y5.skids = catmaid_skids("annotation:NAMK_putative_PAM-y5_RIGHT_complete")
Bprime2a.skids = catmaid_skids("annotation:NAMK_putative_PAM-B'2a_complete")
DANs.skids = c(y5.skids, Bprime2a.skids)

y5 = read.neurons.catmaid(y5.skids)
Bprime2a = read.neurons.catmaid(Bprime2a.skids)
DANs = c(y5, Bprime2a)

# whole neuron clustering
# DP conversion and calculations - /1e3 is crucial
DANs.dots = dotprops(DANs)
DANs.dots <- fetchdp_fafb(DANs.skids)

DANs.matrix = nblast_allbyall(DANs.dots)
DANs.clustered = nhclust(scoremat=DANs.matrix)
# Draw dendrogram of clustering and decide how many classes to split neurons into
plot(DANs.clustered, main='whole neuron morphology')
n = 4 # set based on dendrogram - make this more user-friendly!!!
library(dendroextras)
DANs.divided = colour_clusters(DANs.clustered, k=n)

# Plot neurons, coloured by cluster grouping
plot(DANs.divided, main='whole neuron morphology')
nopen3d()
plot3d(DANs.clustered, k=n, db=DANs, soma=T, lwd=2)
nview3d("frontal")