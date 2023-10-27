# Package building tutorial

https://github.com/flyconnectome/pRecomputed

## Reading

* https://r-pkgs.org/
* https://bookdown.org/rdpeng/RProgDA/building-r-packages.html

This coding club was made up of two prompts and was designed with the new people joining the group in mind;

First prompt: 
- Choose a neuron, whatever you like as long as it has upstream and downstream partners.
- Get its top 3 downstream partners and upstream partners (via fafbseg or natverse)
- Using natverse/Navis, plot all 7 neurons in either 2D or 3D:
    - main one in red
    - upstream 3 in blue
    - downstream 3 in yellow
    - also plot all of the synapse locations between the main neuron and the other 6 as white dots
- Now choose a cell type, and get all the neurons in that cell type from flytable.
- Fetch all the upstream and downstream partners of all the neurons in that type.
- What are the top 3 upstream types and top 3 downstream types?
- Do any of the upstream or downstream types (not just the top 3 up/down stream) also directly interact?

Second prompt: 
(P.S. Do this in iGraph for python and R, but if you're doing python then networkx isn't bad either but it's a bit easier to set up in igraph then convert to networkx after the fact. (Full disclosure: this was not tested on every neuropil, so it's possible that you won't get clusters or get really boring load centralities, apologies.)

- Get the full synapse table.
- Choose one neuropil, limit the synapse table to just synapses in that neuropil.
- Create a directed network based on that limited table.
- If this network is too big, or takes too long, or your coding instance crashes because of size, the best way around this for this exercise is just to randomly select half (or 1/3 or 2/3 or whatever) and use those as the network data.
- What's the diameter of the network? Which pairs of neurons have this diameter? Do they tend to be in the same classes, and if so which class direction does that go in?
- Network diameter is the shortest distance between the two most distant nodes in the network. E.g. it is the longest shortest distance in the network.
- Calculate the closeness centralities of all neurons in the network. Plot the distributions of load centralities across each class. Which class has the highest? The lowest?
- Choose a community algorithm (e.g. fastgreedy) that is available in igraph (or networkX if you don't mind converting between the packages). Run it on the network. How many communities pop up?
- For fun, try grouping the nodes into their assigned communities and plotting the graph with communities as nodes and edges as the total edge weight between all neurons in each respective community.
- As an aside, if you want to do some fun stuff (e.g. the graph embedding I've been doing recently), you can mess around with the karateclub package in python (does require the graph to be in networkx for some reason). A ton of really neat stuff in there, but it's honestly more useful for you to mess around a bit on your own.
