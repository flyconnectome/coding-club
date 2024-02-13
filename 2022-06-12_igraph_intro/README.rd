This coding club prompt was designed to be an introduction to iGraph although it proved complicated and a revised introductory iGraph coding club prompt can be found in the 2023-11-05_igraph_intro folder; 

iGraph is a graph analysis package that exists in both R and Python. 

This prompt is primarily around AL information processing, but really only scrapes the surface of what iGraph can do. 
I encourage you all to mess around and explore other iGraph functions with the graph we're going to be making here.

To make a graph of AL data:
Use Sven’s periodically-generated connectivity per neuropil dataframes (https://drive.google.com/drive/u/0/folders/1g7i3LMmDFcZXDXzevy3eUSrmcMJl2B6a - need to access syn_proof_analysis_filtered_XXX.feather )
    -get all the connectivity in the AL (and perhaps filter appropriately so you don’t have too many rows to work with, e.g. syn_count > 1).
Using info , filter the above dataframe for only ALRNs, ALLNs and ALPNs, to get the connectivity between AL cell types.
Calculate an edge weight metric, namely input proportion per edge:
Getting the total number of post-synapses per neuron in the AL
Divide the number of synapses per edge (per connection between two neurons) by the total number of post-synapses the postsynaptic neuron has.
Create a directed graph in iGraph with edges as calculated above.

Now you have a graph! I'm going to give some fairly basic prompts from here to get you going, but feel free to ignore these and explore something else!
Select a favorite type of ALPNs.
Use a function from iGraph to get everything within 3 hops’ distance, from ALRNs to your PNs of choice. i.e. get all the connections that are: ALRN -> PN, ALRN -> something -> PN, ALRN -> something -> something -> PN.
Here you probably want to ensure that there are no PNs of your choice anywhere except as the last element of the path.
For each path, calculate effectively how much an ALRN contributes to a PN’s total input.
For ALRN -> something -> PN, you want (input proportion (edge weight) from ALRN to something) * (input proportion (edge weight) from something to PN). Record this number, and how many hops was this path.
Make a box and whisker plot, with one box per hop number, showing the distribution of effective ALRN contribution to the PNs
