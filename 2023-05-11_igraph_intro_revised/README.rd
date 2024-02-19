This coding club is an introduction to iGraph, a graph analysis package that exists in both R and Python. This prompt is a simplified and re-focused version of the last prompt, which was made with Yijie’s help.

To make a graph of AL data:
-Use Sven’s periodically-generated connectivity per neuropil dataframes here (https://drive.google.com/drive/u/0/folders/1g7i3LMmDFcZXDXzevy3eUSrmcMJl2B6a - need to access syn_proof_analysis_filtered_XXX.feather ) 
    -get all the connectivity in the AL (and perhaps filter appropriately so you don’t have too many rows to work with, e.g. syn_count > 1).
- Using info table (Note that there is a column in info (root_630) that has the body ID of a neuron at the time that the latest synapse table was made), filter the giant synapse dataframe to keep only synapses where both the pre- and post-synaptic neuron are ALLN or ALPN, as well as neurons where the post-synaptic neuron is an ALLN (this will give us ALINs). This will give us all synapses involved in AL processing.
- Calculate an edge weight metric, namely input proportion per edge:
- Getting the total number of post-synapses per AL neuron.
- Divide the number of synapses per edge (per connection between two neurons) by the total number of post-synapses the postsynaptic neuron has. In python you can calculate the total number of inputs a post-synaptic neuron has via df.groupby(‘body_post’).count(). I leave the division step to you.
- Create a directed graph in iGraph with edges as calculated above.
    -In python you can do this via iGraph.from_dataframe(df) where the first column is pre-synaptic ID, second column is post-synaptic ID, and third column is weight.
- Then, pull the cell classes and types from info (I’d recommend using hemibrain_type as it’s far less sparse) and assign them to the appropriate vertices
                                                                              
This is going to be a fairly quick coding club prompt, so I’m just going to have you play around with creating and plotting smaller graphs from the larger graph.
- First, group the connections by the cell_class of the two involved neurons, summing up all the weights (which are normalised as fractions, but feel free to do this with non-normalised data).
- Turn this dataframe into a directed, weighted graph.
- Plot this graph, making sure the width of the arrows is representative of the strength of the connection between the cell classes.
- Now, group the original connections by the cell_type of the two involved neurons, summing up the weights as before.
- Now, keep only the top 30 or 40 or whatever strongest connections, and put those into a graph.
- Plot this graph, this time note that you should expect to see several smaller, unconnected graphs in the plot instead of one central plot as you should have seen before.
- Now choose a favourite ALLN type
- From the cell type table you made previously, go ahead and grab everything that has a pre or post type of the cell type you choose
- Make a graph from it and plot it.
