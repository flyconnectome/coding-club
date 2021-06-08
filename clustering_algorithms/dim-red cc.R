library(neuprintr)
library(tidyverse)#call packages
library(Rtsne)
library(umap)
library(scatterplot3d)

nrns <- data.frame(
  ids= c(633546217, 416642425, 634962055, 5813027103, 788794171, 694920753, 948709216,
         1011447819, 918334668, 949710555, 917647959, 919763043, 1036637638, 858587718,
         1228692168, 1198330641, 1730608428, 5813060726, 541127846, 978733459, 1043825714),
  types= c('EPG', 'EPG', 'EPG', 'EPG', 'EPG', 'EPG', 'ExR1', 'ExR1', 'ExR1', 'ExR1', 'ExR1',
           'ExR3', 'ExR3', 'ExR4', 'ExR4', 'ExR4', 'ExR4', 'ExR5', 'ExR5', 'ExR5', 'ExR5')
)
#colcode for plotting
col <- c("EPG"="red","ExR1"="blue","ExR3"="green","ExR4"="yellow", "ExR5"="purple")

#function definition. 
checkd <- function(ids=ids){
  df <- neuprint_get_meta(ids, field = "bodyid")
  if(length(setdiff(ids,df$bodyid))==0)
  {message("All present")}
  else
  {message(paste0(setdiff(ids,df$bodyid), " not present in Neuprint\n"))}
}

nsyns <- neuprint_get_synapses(nrns$ids)#get synapses 

nsyns <- filter(nsyns,nsyns$confidence >=0.9)#only those above 0.9 confidence
nsyns %>% group_by(bodyid) %>% mutate(prepostrat=as.numeric(length(nsyns$prepost[nsyns$prepost==1])/length(nsyns$prepost[nsyns$prepost==0]))) -> nsrat   #find ratio of pre to post synapses; doesnt work why 
nsrat <- data.frame() #diff way
nsrat <- lapply(nrns$ids, function(x){ #finding rat of pre to post syns
  df <- data.frame(ids=x, prepostrat=length(nsyns$prepost[nsyns$prepost==1 & nsyns$bodyid==x])/length(nsyns$prepost[nsyns$prepost==0 & nsyns$bodyid==x])) #make df per bodyid. and find pre/post
  nsrat <- as.data.frame(rbind(nsrat, df)) #merge together
})
nsrat <- as.data.frame(rbindlist(nsrat))  #change from list to data.table to df
nnos <- as.data.frame(table(nsyns$bodyid, nsyns$partner)) #get neuron_partners_summary
colnames(nnos)[1] <- "ids"
colnames(nnos)[2] <- "partner"
unique(nnos$ids)

#cluster with top partners
nnos %>% group_by(ids) %>% slice_max(order_by = Freq, n=100) -> nnostop #get top 100 partners for each bodyid
nnostop %>% merge(nrns, by.x = "ids", by.y = "ids", all.x = T) %>% mutate(cols=col[types])-> nnostypetop #merge neurontype data
nnostypetop_wide <- pivot_wider(nnostypetop, names_from = "partner", values_from = "Freq") #wide form for dimensionality reduction
nnostypetop_wide[is.na(nnostypetop_wide)] <- 0 #replace NA with 0
rownames(nnostypetop_wide) <- nnostypetop_wide$ids #rownames = ids

prmat <- nnostypetop_wide[,!colnames(nnostypetop_wide) %in% c("ids", "types","cols")] #create matrix for dim red
rownames(prmat) <- nnostypetop_wide$ids #rownames=ids
prnnos <- prcomp(prmat, scale. = T) #pca with scaling before variance. variables should have unit variance?
summary(prnnos)
prnnos$x %>% as.data.frame() %>% rownames_to_column("ids") %>%  merge(nrns, by.x = "ids", by.y = "ids", all.x = T) %>% mutate(colstype=col[types]) %>% 
  ggplot(aes(x=PC1, y=PC2,col=types)) + geom_point() -> toppca #change pca result to df; rownames=ids; merge info from nrns again; add col code; plot.
toppca

#cluster with all partners. clustering not good why?
nnos_wide <- pivot_wider(nnos, names_from = "partner", values_from = "Freq")  #with all partners. wide form
rownames(nnos_wide) <- nnos_wide$ids

prmatfull <- nnos_wide[,!colnames(nnos_wide) %in% c("ids")]
rownames(prmatfull) <- nnos_wide$ids
prnnosfull <- prcomp(prmatfull, scale. = T)
# summary(prnnosfull)
prnnosfull$x %>% as.data.frame() %>% rownames_to_column("ids") %>%  merge(nrns, by.x = "ids", by.y = "ids", all.x = T) %>% mutate(colstype=col[types]) %>% 
  ggplot(aes(x=PC1, y=PC2,col=types)) + geom_point() -> toppcafull
toppcafull

#TSNE now
#what is perplexity. optimal value? layout of plt changes for same parameters with each run. max perplexity for this case = 6 
tsne <- Rtsne(as.matrix(prmat),perplexity=5)
tsnemat <- tsne$Y
rownames(tsnemat) <- rownames(prmat)
tsnemat %>% as.data.frame() %>% rownames_to_column("ids") %>% merge(nrns, by.x = "ids", by.y = "ids", all.x = T) %>%
  ggplot(aes(x=tsne$Y[,1], y=tsne$Y[,2], col=types)) + geom_point() +labs(x = "T-SNE 1", y = "T-SNE 2", colour = "Types") -> tsneggplt
tsneggplt

#TSNE_all 
# > tsne_all <- Rtsne(prmatfull,perplexity=6)
# Error: protect(): protection stack overflow
#Error because of 35000 columns? increase --max-ppsize; Cstack_info(). turning first into matrix helps.
tsne_all <- Rtsne(as.matrix(prmatfull),perplexity=5)
tsnemat_all <- tsne_all$Y
rownames(tsnemat_all) <- rownames(prmatfull)
tsnemat_all %>% as.data.frame() %>% rownames_to_column("ids") %>% merge(nrns, by.x = "ids", by.y = "ids", all.x = T) %>%
  ggplot(aes(x=tsne_all$Y[,1], y=tsne_all$Y[,2], col=types)) + geom_point() +labs(x = "T-SNE 1", y = "T-SNE 2", colour = "Types") -> tsneggpltall
tsneggpltall

#no of neighbours? how to choose n_neighbours?how to read?
# UMAP2d
umapdata2d <- umap(as.matrix(prmat),n_neighbors=3, n_components = 2) 
umapdata2d$layout %>% as.data.frame() %>% rownames_to_column("ids") %>% merge(nrns, by.x = "ids", by.y = "ids", all.x = T) %>%
  ggplot(aes(x=V1, y=V2, col=types)) + geom_point() +labs(x = "UMAP 1", y = "UMAP 2", colour = "Types") -> umapplt
umapplt

# UMAP2d_all
umapdata2d_all <- umap(as.matrix(prmatfull), n_neighbors= 5) 
umapdata2d_all$layout %>% as.data.frame() %>% rownames_to_column("ids") %>% merge(nrns, by.x = "ids", by.y = "ids", all.x = T) %>%
  ggplot(aes(x=V1, y=V2, col=types)) + geom_point() +labs(x = "UMAP 1", y = "UMAP 2", colour = "Types") -> umapplt_all
umapplt_all

#UMAP3d
umapdata <- umap(as.matrix(prmat),n_neighbors=5, n_components = 3) 
umapdata$layout %>% as.data.frame() %>% rownames_to_column("ids") %>% merge(nrns, by.x = "ids", by.y = "ids", all.x = T) -> umappltdata
with(umappltdata,scatterplot3d(umappltdata$V1,umappltdata$V2,umappltdata$V3, color = col[umappltdata$types], xlab = "UMAP 1", ylab = "UMAP 2", zlab = "UMAP 3"))
with(umappltdata,plot3d(umappltdata[!colnames(umappltdata) %in% c("ids", "types")], col = col[umappltdata$types],xlab = "UMAP 1", ylab = "UMAP 2", zlab = "UMAP 3",
                        legend=T)) 

#UMAP3d_all
umapdata_all <- umap(as.matrix(prmatfull),n_neighbors=5, n_components = 3) 
umapdata_all$layout %>% as.data.frame() %>% rownames_to_column("ids") %>% merge(nrns, by.x = "ids", by.y = "ids", all.x = T) -> umappltdata_all
with(umappltdata_all,scatterplot3d(umappltdata_all$V1,umappltdata_all$V2,umappltdata_all$V3, color = col[umappltdata_all$types], xlab = "UMAP 1", ylab = "UMAP 2", zlab = "UMAP 3"))
with(umappltdata_all,plot3d(umappltdata_all[!colnames(umappltdata_all) %in% c("ids", "types")], col = col[umappltdata_all$types],xlab = "UMAP 1", ylab = "UMAP 2", zlab = "UMAP 3",
                        legend=T)) 


