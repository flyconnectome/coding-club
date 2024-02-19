In the most recent journal club we discussed this paper (https://www.biorxiv.org/content/10.1101/2022.04.05.487221v1) which used the cortex neurite length (the cable length from the soma to where the neuron enters a neuropil of interest). 

In this coding club, the goal is to recreate this measure and use it to compare morphologies of one hemilineage by their predicted age.

General Prompt:
Choose ring neurons from the main FlyTable. Isolate the cable from soma to where the axon cable enters the ellipsoid body and determine that distance for each neuron. 
Determine if the morphologies of ring neurons correlate with their age predicted by cable length.

Second level of the prompt; 
Here is the slightly more detailed version, but again the goal here is not to give away exactly what to do but to point you in a correct direction and ensuring you’re thinking of the right questions.
1. Ring neurons are identified in the main FlyTable as having “ring neuron” in their cell_class column. The first step, then, is to extract these nicely from the table.
2. The meat of this prompt is in getting the cable length of the neurite from soma to the axon. This is not trivial. What are the functions in Navis that make this possible? How will you ensure that you can make a generalizable function that allows you to ignore the dendritic part of the neuron? Plotting outputs of different Navis functions is very helpful.
3. The more trivial part of this is finding the distance from the soma to where the main axonal neurite (the Navis longest_neurite function is very useful.) enters the EB. You will probably need the mesh of the EB body, which I’ve attached here. The geodesic distance/cable length to the entry point is the real goal of this prompt.
4. Now just nblast all by all, cluster appropriately, and plot cluster vs cable length. (Also, in the spirit of making it look pretty, it is probably useful to sort the clusters based on their average cable length so the plot is readable.
