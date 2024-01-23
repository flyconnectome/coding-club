Here is the prompt, it involves fetching partners and visualisation of neurons. For this we will use FAFB data and you can download a copy of the info table from here; 
https://github.com/flyconnectome/flywire_annotations/blob/main/supplemental_files/Supplemental_file1_neuron_annotations.tsv 
regardless of if you have access to the info table or not) which you will need to read into R/Jupyter Notebook to carry out the task. Make sure that the root ids in the root_id column are fully visible and not written in scientific form.
A. Choose one neuron (from the root_id column in the dataframe). It should be
  - fully reconstructed
  - have upstream and downstream partners
  - and not be a singleton or a Kenyon cell (KC) neuron.
Here are some suggestions of some hemibrain types in the dataframe from which you could pick a neuron, but feel free to pick your own; AVLP308, AVLP316, AVLP370, AVLP390, AVLP409, CL004, CLO083, CL282, CRE018, CRE027, SAD012
B. Get the neuron's top 3 downstream partners and top 3 upstream partners and the location of their respective synapses (via flywire_partners(details = TRUE) in R or flywire.get_synapses in python - more info for python users here
https://fafbseg-py.readthedocs.io/en/latest/source/tutorials/flywire_connectivity.html).
  - To exclude bad synapses you can filter by cleft_score (>50).
  - To count the number of synapses, you should count the number of occurrences for each pair of post_id and pre_ids.
C. You can perform two visual analyses from this dataframe;
  Plot (use the plot3d command in R) the main neuron in dark red, the synapse locations with downstream partners in medium red and the synapse locations with upstream partners in light red (i.e. use a colour scale/gradient). 
    - To do this you need to download the l2 skeletons/mesh for the main neuron
    - take frontal and posterior view pictures of this plot with the brain template (retrieve the brain template from the elmr package in R and from here for python users)
to specify these views, use nview3d in R and to plot in Jupyter Notebook use navis.plot3d which returns a plotyly.Figure object that contains the settings for the plot, including camera positions. Here is a tutorial on how to adjust the camera;
https://plotly.com/python/3d-camera-controls/
to access the brain template in R you can use plot3d(elmr::FAFB.surf) and in python you can find information here (https://navis.readthedocs.io/en/latest/source/tutorials/plotting.html#adding-volumes).
  Plot the neurons in a neuroglancer scene, where the main neuron is in one tab and is red, the downstream neurons are in another tab and are blue and the upstream neurons are also in their own tab and are green.
D. Now choose a type (like one of the ones listed in a.iv) and get all the neurons in that type.
E. What are the top 3 upstream types and top 3 downstream types ?
