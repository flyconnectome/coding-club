# ### First half - takes ages, do in advance
# all_downstream = read.neurons.catmaid("annotation:^FML - downstream of DA2$")
# old_downstream = read.neurons.catmaid("annotation:^FML - downstream of first DA2$")
# new_downstream = setdiff(all_downstream, old_downstream)
# 
# # whole neuron clustering
# # DP conversion and calculations - /1e3 is crucial
# dots = dotprops(all_downstream/1e3)
# matrix = nblast_allbyall(dots)
# 
# # Save results
# saveRDS(old_downstream, file="Rclub20181024-old_downstream.rds")
# saveRDS(new_downstream, file="Rclub20181024-new_downstream.rds")
# saveRDS(matrix, file="Rclub20181024-matrix.rds")



### Second half - read in results from first half
old_downstream = readRDS(file="~/Desktop/KJH_Rcub_20181024/Rclub20181024-old_downstream.rds")
new_downstream = readRDS(file="~/Desktop/KJH_Rcub_20181024/Rclub20181024-new_downstream.rds")
all_downstream = c(old_downstream, new_downstream)
matrix = readRDS(file="~/Desktop/KJH_Rcub_20181024/Rclub20181024-matrix.rds")
clustered = nhclust(scoremat=matrix)

# Draw dendrogram of clustering and decide how many classes to split neurons into
plot(clustered)
n = 27 # set based on dendrogram - make this more user-friendly!!!
divided = dendroextras::colour_clusters(clustered, k=n, col=sample(rainbow(n)))
# Plot neurons, coloured by cluster grouping
plot(divided)

# Grouping by clustre and sample
groups = dendroextras::slice(clustered, k=n)

all_skids = catmaid_skids("annotation:^FML - downstream of DA2$")
old_skids = catmaid_skids("annotation:^FML - downstream of first DA2$")
new_skids = setdiff(all_skids, old_skids)

# 3D plotting
old_cols = colorRampPalette(c("red","purple3"))(n)
new_cols = colorRampPalette(c("goldenrod1","forestgreen"))(n)
nopen3d()
for (i in 1:length(groups)){
  if (names(groups[i]) %in% old_skids){
    plot3d(all_downstream[names(groups[i])], col=old_cols[groups[i]], soma=T, lwd=2)
  } else if (names(groups[i]) %in% new_skids){
    plot3d(all_downstream[names(groups[i])], col=new_cols[groups[i]], soma=T, lwd=2)
  }
}
nview3d("frontal")

# Bar chart
old_groups = vector("numeric", n)
new_groups = vector("numeric", n)

for (i in 1:length(groups)){
  if (names(groups[i]) %in% old_skids){
    old_groups[groups[i]] = old_groups[groups[i]] + 1
  } else if (names(groups[i]) %in% new_skids){
    new_groups[groups[i]] = new_groups[groups[i]] + 1
  }
}

old_groups_rel = old_groups / sum(old_groups)
new_groups_rel = new_groups / sum(new_groups)

group_table = matrix(c(old_groups_rel, new_groups_rel), nrow=2, byrow=T)

barplot(group_table, main="Cluster identity by sample", xlab="Cluster identity", col=c("red","goldenrod1"),
        names.arg=1:27, cex.names=0.8, legend = c("First sample", "Second sample"), args.legend=list(x="top"), beside=TRUE)
