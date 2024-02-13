Task 1
- Read neurons of the hemilineage AOTUv4_ventral  in the fafb_hemilineages_survey_right sheet.
- Remove duplicates and choose complete/adequate neurons for further analyses.
- Prune/simplify neurons as you see fit and divide into distinct morphological types.

Task 2
- Find the downstream and upstream connections for each neuron.
- Write a function which returns the percentage of innervation of a given neuron in different neuropil (see nat::pointsinside()).

Task 3
- Find which neuropil each neuron innervates. Obtain a dataframe with the percentage of innervation (percent connections in a given neuropil region) in each neuropil for each neuron.
- Plot and compare the percentage innervations in each neuropil for the different morphological types (brownie points if data is segregated by input & output synapses and/or axon & dendrites)

Task 4
- Obtain a feature matrix where the rows are the neuron ids and columns are neuropil regions and each cell is the percentage of synapses of that neuron in that particular neuropil region.
- Apply TSNE/UMAP to reduce dimensions and see if morphological types cluster together according to their innervation patterns.
