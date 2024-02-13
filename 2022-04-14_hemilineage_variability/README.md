- For Python you will need Fafbseg, Navis, and NeuPrint-Python. 
- For anyone else coding in R, you will require fafbseg, nat, hemibrainr, neuprintr(for hemibrain queries) for doing most of the major analyses.
- It’s also important to know that for the Hemibrain data via NeuPrint, the cell body fibre (CBF) data roughly but imperfectly correlates to the hemilineage identity, and that conversion is found here (https://drive.google.com/file/d/1FeXRRQL-TbJu0fy1ORjk69LgTVZOpbiB/view).
- Also note that there are more predicted flywire synapses than hemibrain: you may need a bigger threshold for FlyWire (e.g. 5 synapses) than hemibrain (1 or 2 synapses).

Variable Hemilineage-Hemilineage Connectivity. (EASY)
- For hemilineage PSp3_dorsal, find all strong upstream and downstream partners on the FlyWire left side, right side, and the Hemibrain data.
- For Flywire, use the info table (in Python use Sea-Serpent to query programatically) to determine the hemilineage (where possible) of these partners. For Hemibrain data use the CBF-Hemilineage conversion.
- Plot hemilineage innervation data (upstream and downstream) for all three PSp3_dorsal sets.
- Compare the variability (ideally with a statistic) of hemilineage innervation between the three hemilineage sets.


Variable Hemilineage Region Innervation. (HARD)
- For hemilineage PSp3_dorsal, find the neuropil/region of interest of all upstream and downstream synapses on the FlyWire left side, right side, and the Hemibrain data.
- In NeuPrint, you can simply ask for the ROI, while in FlyWire you will have to check the location to the neuropil meshes (these are attached).
- You will probably need to loop through each synapse location and determine if it’s in the mesh for each neuropil region.
- Also important to note that the neuropils are a bit different between FAFB and hemibrain: e.g. in hemibrain the MB is divided into CA, PED, alpha, beta, alpha’, beta’ and gamma, but in FlyWire it’s CA, ML, PED, VL. It may be easier to just choose the primary neuropils in hemibrain as those are consistent (far as I can tell). You can list all primary ROIs in hemibrain in Python with roi_tree_text = fetch_roi_hierarchy(True, True, format='text').
- Plot neuropil/ROI innervation data (upstream and downstream) for all three PSp3_dorsal sets.
- Compare the variability (ideally with a statistic) of region innervation between the three hemilineage sets.


Plot locations of pre- and post-synapses for chosen hemilineage in all 3 sets. (Choose your own difficulty)
- I would suggest 3 different plots.
- If you need to, in Python you can use navis.xform_brain([data], source='FLYWIRE', target='JRC2018F') to transform Hemibrain locations to FlyWire locations.
- Make this as pretty as possible, I’m personally envisioning something similar to Fig. 4A in this paper (https://elifesciences.org/articles/67510), but for one hemilineage instead of two.
