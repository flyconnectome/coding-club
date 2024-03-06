## coding club 08/06/2021 
# 0. Configure neuprint connection
# 1. Warm-up task: write a function that tells whether dataset is available in neuprint datasets or not.
# 2. Load all the synapses per neuron (nrns$id) to a list (hint: neuprint_get_synapses)
# 3. Filter out all synapses with confidence less than 0.9
# 4. Count the ratio of pre to post synaptic connections per each neuron.
# 5. Count number of connection that neuron makes per partner.
# 6. Construct a feature matrix from synapses counts (prev. point):
#   - It should have synaptic partners as columns
# - and target neurons as rows.
# 7. Run PCA (prcomp), TSNE and UMAP (see docs of libraries above) algorithms on feature matrix and reduce dimensionality to only 2 variables
# 8. Plot the results of  each method as a scatter plot (+ colour types of neurons on the plot).
# 9. Compare the results. 

library(neuprintr)
library(tidyverse)
library(Rtsne)
library(umap)
library(RColorBrewer) # optional
library(randomcoloR)

nrns <- data.frame(
  ids= c(633546217, 416642425, 634962055, 5813027103, 788794171, 694920753, 948709216,
         1011447819, 918334668, 949710555, 917647959, 919763043, 1036637638, 858587718,
         1228692168, 1198330641, 1730608428, 5813060726, 541127846, 978733459, 1043825714),
  types= c('EPG', 'EPG', 'EPG', 'EPG', 'EPG', 'EPG', 'ExR1', 'ExR1', 'ExR1', 'ExR1', 'ExR1',
           'ExR3', 'ExR3', 'ExR4', 'ExR4', 'ExR4', 'ExR4', 'ExR5', 'ExR5', 'ExR5', 'ExR5')
)

# 1. Warm-up task: write a function that tells whether dataset is available in neuprint datasets or not. 
query_neu_dataset <- function(query){
  return(any(grepl(query, names(neuprint_datasets()))))
}

# 2. Load all the synapses per neuron (nrns$id) to a list (hint: neuprint_get_synapses)
nrns.syn <- neuprint_get_synapses(nrns$ids)

# 3. Filter out all synapses with confidence less than 0.9
nrns.syn <- nrns.syn[nrns.syn$confidence>=0.9,]

# 4. Count the ratio of pre to post synaptic connections per each neuron.
prepost_bodyid <- as.data.frame(with(nrns.syn, table(prepost, bodyid)))
prepost_bodyid <- pivot_wider(prepost_bodyid, names_from = prepost, values_from = Freq)
names(prepost_bodyid)[2:3] <- c('output', 'input')
prepost_bodyid$prepost_ratio <- prepost_bodyid$input / prepost_bodyid$output

# 5. Count number of connection that neuron makes per partner.
# 6. Construct a feature matrix from synapses counts (prev. point):
#   - It should have synaptic partners as columns
# - and target neurons as rows.
ncon <- with(nrns.syn, table(bodyid, partner))

# 7. Run PCA (prcomp), TSNE and UMAP (see docs of libraries above) algorithms on feature matrix and reduce dimensionality to only 2 variables
# prcomp() wants observations to be rows 
pca <- prcomp(t(ncon))
tsne <- Rtsne(ncon, perplexity = 6)

# UMAP wants observations to be columns 
ncon.table <- pivot_wider(as.data.frame(ncon), names_from = partner, values_from = Freq)
ncon.data <- ncon.table[,-1]
ncon.labels <- ncon.table$bodyid
ncon.umap <- umap(ncon.data)

colours <- distinctColorPalette(length(unique(nrns$types)))
# 8. Plot the results of  each method as a scatter plot (+ colour types of neurons on the plot).
# 9. Compare the results. 
# nrns$types[match(colnames(ncon), as.character(nrns$ids))] this matches the sequence of types according to the sequence of appearance of ids in ncon 
# plot PCA 
plot(pca$x[,1],pca$x[,2], 
     col = colours[as.factor(nrns$types[match(colnames(ncon), as.character(nrns$ids))])], 
     main = 'PCA')
# two ways of adding legends 
# plot t-SNE 
plot(tsne$Y, col = colours[as.factor(nrns$types[match(colnames(ncon), as.character(nrns$ids))])])
legend('bottomleft', legend = unique(nrns$types), text.col = colours[as.factor(unique(nrns$types))])

plot(ncon.umap$layout[,1], ncon.umap$layout[,2], 
     col =colours[as.factor(nrns$types[match(ncon.labels, as.character(nrns$ids))])], 
     main = 'UMAP')
text(x = ncon.umap$layout[,1], 
     y = ncon.umap$layout[,2], 
     pos = 3, 
     cex = 0.5, 
     col =colours[as.factor(nrns$types[match(ncon.labels, as.character(nrns$ids))])], 
     labels = nrns$types[match(ncon.labels, as.character(nrns$ids))])


