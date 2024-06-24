This task involves the identification of neurotransmitters with an added bonus of writing your own function. We will use the publicly available FlyWire data for this exercise, and it can be downloaded from [here](https://github.com/flyconnectome/flywire_annotations/blob/main/supplemental_files/Supplemental_file1_neuron_annotations.tsv).

**Circuit Neurotransmitters**

Overview: Here you will examine neurotransmitter expression in a short circuit in the brain. You will look for the top neurotransmitters expressed at each step. This circuit will start with an olfactory receptor neuron (ORN) and finish when you reach a descending neuron (DN).

Instructions:
1. Start with an ORN, I recommend ORN_DA1 but you are not restricted to this type (although if you use another type there may be more hops before you reach a DN).
2. Look up its downstream partners. What neurotransmitters are they expressing ? (You can examine the neurotransmitters the downstream partners express in the top_nt column).
3. Calculate the number of synapses for each neurotransmitter.
4. Now you need to repeat steps 2-3 until you have a DN type included in your downstream partners (if you start with ORN_DA1 you should only need to repeat this once).
5. Finally, plot only the neurons expressing the top two neurotransmitters at each hop.
    - You do not need to plot all of the neurons expressing the top two neurotransmitters at each hop, just pick a few of them.
    - Colour-code the neurons according to their neurotransmitter and order. If the same neurotransmitter is expressed by first and second order neurons, create a colour gradient for that neurotransmitter, e.g. first order neurons expressing gaba in a lighter green and second order neurons expressing gaba in a darker green.
    - Use plot3d(elmr::FAFB.surf, alpha=.1) to plot the FAFB brain mesh in r, and more information can be found here for python users.


**Function Writing:**

Write your own function to automatically identify the neurotransmitters expressed by the downstream neurons of a given type, and calculate the number of synapses for each neurotransmitter. 
Insert print("Fetching downstream partners") at the appropriate location so that the "Fetching downstream partners" message appears onscreen while the function is loading.
