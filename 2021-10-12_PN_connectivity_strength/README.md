Task description:

*note that the suggested commands are for python users

1. Get PNs from the FlyWire dataset (fafbseg.flywire.get_annotations('cambridge_celltypes')).
- Prune/simplify as you want.
- Split into cell_types and L/Rs (the last letter in cell_types column in the return from get_annotations is either L or R).

  
2. Get neurons downstream of each PN neurons (fetch_connectivity).
- Make histograms of connection strengths for all cell types in left and right (separate graphs as you see fit).
- For one of the cell types, on both left and right, plot the connection strength vs average distance (including std. dev bars) from soma (of the PN neurons) to synapse location (use fetch_synapses to get x, y, z location of pre-synapse) for both L and R. (Bonus points for geodesic, I’m sticking w/ euclidean because I’m not sure how geodesic works yet).


3. Find the most likely neurotransmitter for each PN neuron.
- Plot the average number of synapses (w/ std. dev bars) for each NT.
- Plot the average connection strength (w/ std. dev bars) for each NT.
