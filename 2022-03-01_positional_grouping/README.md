This exercise is an attempt to look at whether or not neurons that are close together in space also connect to each other.

- Choose a location in FlyWire! I’d say choose something from something you’ve been working in (e.g. AL, LH, or some area where a bunch of neurons in a hemilineage run together. If you have other suggestions or ideas to make this analysis more interesting, please say so!)

- Find and display all neurons within a 400 nm diameter square in the same Z coordinate plane but centred at your starting location. For example, if I start at x,y,z of 1600,1200,400, I want everything from X: 1400-1800, Y: 1000-1400, Z:400.

- Get upstream and downstream connectivity of these neurons.

- Plot adjacency matrix for these neurons.

- Note any patterns in the adjacent matrices. 



This next exercise attempts to determine if unilateral RNs in the AL tend to cluster in space.

- Here are 5 unilateral RN IDs, some are ipsilateral and some are contralateral: 720575940620639002, 720575940607626453, 720575940621958596, 720575940633731901, 720575940637817021, and here are 5 bilateral RN IDs: 720575940610763762, 720575940620360948, 720575940605326537, 720575940634057976, 720575940632766620. (Feel free to find your own favourites from the AL_bodies table, but the labelling on unilateral vs bilateral is not really existent).

- Select a location along each of the RNs (ideally where the z plane is perpendicular to the neuron)

- Find all neurons within a 200 nm radius sphere or 400 nm side length cube of the selected location for each RN. (Such that the location selected is in the centre of sphere/cube).

- Determine if those neurons are unilateral or bilateral (synapse location is probably the best metric for it).

- Are neurons near the unilateral RNs more likely to be unilateral than those near the bilateral neurons?
