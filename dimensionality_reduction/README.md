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
