library(neuprintr)
library(tidyverse)

# 0) configure Neuprint connection
neuprint_server <- "https://neuprint-test.janelia.org"
neuprint_token <- "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImRra3J6ZW1AZ21haWwuY29tIiwibGV2ZWwiOiJyZWFkd3JpdGUiLCJpbWFnZS11cmwiOiJodHRwczovL2xoMy5nb29nbGV1c2VyY29udGVudC5jb20vYS9BQVRYQUp6c1FyeXBiLXMxNXhsYXBQSEFUT1VWc3kwOGZTZFZMWWJIeUpIcj1zOTYtYz9zej01MD9zej01MCIsImV4cCI6MTgwMDM5NTQ5OH0.oECSjiB2OobdWR0q48KMP_xilTfOS9W7p-mbNL5lyrI"
neuprint_ds <- "hemibrain:v1.0.1"
conn = neuprint_login(server= neuprint_server,
                      token= neuprint_token,
                      dataset = neuprint_ds)

# 1) Warm up task: Construct a function that tells whether dataset is in neuprint or not

is_in_neuprint <- function(ds) ds %in% names(neuprint_datasets())

nrns <- data.frame(
  ids= c(633546217, 416642425, 634962055, 5813027103, 788794171, 694920753, 948709216,
              1011447819, 918334668, 949710555, 917647959, 919763043, 1036637638, 858587718,
              1228692168, 1198330641, 1730608428, 5813060726, 541127846, 978733459, 1043825714),
  types= c('EPG', 'EPG', 'EPG', 'EPG', 'EPG', 'EPG', 'ExR1', 'ExR1', 'ExR1', 'ExR1', 'ExR1',
            'ExR3', 'ExR3', 'ExR4', 'ExR4', 'ExR4', 'ExR4', 'ExR5', 'ExR5', 'ExR5', 'ExR5')
)

# 2) read all the synapses per neuron to a list
synapses <- lapply(nrns$ids, function(x) neuprint_get_synapses(neuprint_ids(x), dataset = neuprint_ds))

# 3) filter out synapses with confidence less than 0.9
conf_syn <- 0.9

synapses <- lapply(synapses, function(s) s %>% filter(confidence > conf_syn))

# 4) count the ratio of pre to post synaptic connections per each neuron
## 0 a downstream, postsynaptic
## 1 n upstream, presynaptic
prepost_ratios <- lapply(synapses, function(s){
  tt <- as.data.frame(table(s$prepost))
  tt[tt$Var1==1,]$Freq / tt[tt$Var1==0,]$Freq
})
names(prepost_ratios) <- nrns$ids
prepost_ratios

# 4) group synapses over partner

gs <- lapply(synapses,
             function(s) s %>% group_by(partner, prepost) %>%
               count() %>% mutate(n2 = ifelse(prepost>0, n, -n)) %>%
               select(-c(prepost, n))
             )
names(gs) <- nrns$ids

gs <- lapply(synapses,
             function(s) {
               ns <- s %>% group_by(partner) %>%
                count()
            })

# 6) Construct the feature matrix from synapses counts
## It should have synaptic partners as columns
## and target neurons as rows
feature_mat <- map_dfr(gs, ~.x %>% pivot_wider(names_from = partner, values_from = n)) %>%
  mutate(across(everything(), ~ifelse(is.na(.), 0, .)))

feature_mat <- as.matrix(feature_mat)

# 7 & 8 & 9)
# Run PCA, TSNE and UMAP algorithms on feature matrix and reduce dimensionality to only 2 variables
## Plot the results as scatter plot (+ colour types of neurons on the plot)
## Compare the results

library(Rtsne)

tsne_out <- Rtsne(feature_mat,pca=FALSE,perplexity=3,theta=0.0) # Run TSNE

coln <- RColorBrewer::brewer.pal(length(unique(nrns$types)),"Spectral")
names(coln) <- unique(nrns$types)

library(umap)
umap_out <- umap(feature_mat, n_neighbors=4)

# pca
pca_out <- prcomp(feature_mat) #scale. = T


layout(matrix(c(1,2,3), 1, 3, byrow = TRUE))

plot(tsne_out$Y,col=coln[nrns$types], asp=1)
title('tSNE')
plot(umap_out$layout,col=coln[nrns$types], asp=1)
title('UMAP')
plot(pca_out$x[,1:2],col=coln[nrns$types])
title('PCA')
