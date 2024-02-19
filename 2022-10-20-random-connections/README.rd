This coding club deals with the question; Is local connectivity specific or random?


If we presume that local connections are random, and simply occur due to two neurons being in close proximity, then it follows that the more arbours there are of one neuron within radius r of a target neuron, then the more likely this neuron makes connections with the target neuron. If there is non-random connectivity, however, there is unlikely to be a correlation between arbour counts within r and number of connections between the two neurons. The goal for this coding club is to test these two hypotheses.

Make a function that takes an x,y,z location (p) in FlyWire and a radius length r (in either voxels or nms), and n (number of points sampled per side).
This function should return a list of voxel locations evenly distributed within a sphere around point p with radius r. Feel free to mess around with how dense the distribution of voxel locations is.
One possible way to do this:
    - Create a cube with size 2r that is centered at p.
    - For the cube with side length l, get n points per side (with l/n distance between each point) (n can/will vary significantly depending on how large r is). This will get you 3 lists (x_list, y_list, z_list) of equal size.
    - To evenly sample across the cube then, get all possible combinations of points made of one element from each list (x_list[i], y_list[j], z_list[k]). This will give you a list of locations (p_list).
    - Remove all locations in p_list where the euclidean distance to p > r.

There are other ways to do this though:
    - Choose a neuron, and set p as a point in the axon of the neuron. 
    - Run the function you described above with different r values until you get a somewhat normal looking distribution of counts of root Ids.
    - Fetch the root IDs at each of the locations within the sphere. This should be a general quantification of amount of arbour near the target location. You will want to make sure you know how many times each root ID appears within the set of points you constructed earlier.
        - Optional: feel free to restrict this to juse proofread neurons, or if that is messy then just neurons that are above a certain size. Try a few things until you get a good understanding.
    - Fetch the synapses from the target neuron (the neuron that is located at p). Of the synapses that are within the sphere around p, fetch the root IDs of the downstream (or upstream if you’re looking at a dendrite area) neurons.
    - Plot arbour amounts vs. synapse number. Plot the line of best fit and the R-squared value for this correlation (if it’s non-linear see if you can fit a function to it).
    - Does the correlation or the R-squared vary as you vary radius r? Test a few locations in FlyWire to see if different neuropils have different values.
    - Bonus challenge: Instead of focusing on a specific neuron, fetch all synapses within the sphere and ask if higher arbour counts are correlated with more synapses.
