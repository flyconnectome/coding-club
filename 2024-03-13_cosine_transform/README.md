The prompt for this task has two objectives; 1) you will perform cosine clustering for neurons between two datasets and 2) plot these neurons in the same space (i.e. perform a template brain transform). You will use data from the FAFB and maleCNS datasets for this task.
  - You can access the published FAFB data from here (https://github.com/flyconnectome/flywire_annotations/blob/main/supplemental_files/Supplemental_file1_neuron_annotations.tsv) , and
  - can access the malecns data using the neuprintr package in R - first make sure to login to neuprint  using the command neuprint_login(server="https://neuprint-cns.janelia.org", dataset = "cns")
    or by using the clio-py package in Python.

**Task #1 - Cosine clustering between datasets**

Pick a brain cell type that has been identified in both the FAFB (column name hemibrain_type) and malecns (column name type) datasets. Feel free to pick any cell type that is only in the brain, such as any visual (projection/centrifugal) neurons, MBONs, or Fru+ - related neurons. Here are some examples of types that you can use if you don't already have a favourite one in mind;
MBON01, MBON14, AVLP429, LT36, LT40.
  - Next you need to pick 4/5 other types to use for the cosine analysis. For this you can use the intersect() function in R and intersection() in Python (I think!) to search for more central brain/visual projection/visual centrifugal neurons that also exist in both datasets. 
  - Use the coconatfly package in R or the cocoa package in Python to run separate cosine plots per dataset AND/OR plot the neurons from both datasests onto one graph (I like to use the interactive = TRUE option, especially when looking at a lot of neurons, and you will need to specify the dataset by using dataset = 'flywire' or dataset = 'malecns' , or datasets = c('flywire', 'malecns') if you are looking at the neurons from the two datasets together. Are there any differences in connectivity between the two datasets ? why do you think that is ?
  - For the Python users, here is a super quick example for using cocoa to co-cluster FlyWire and MCNS neurons. Make sure you update both fafbseg and cocoa to the most recent version;
    import cocoa as cc

Use the high-level convenience function

          `x` and `y` can be lists of IDs or cell types
          cl = cc.generate_clustering(fw=x, mcns=y).compile()

To get the distances

          cl.dists_

To create a clustermap

          cl.plot_clustermap()

Have a look at the docstrings of the various functions to learn more.

**Task #2 - Template brain transform**

  - You will first need to download the l2 skeletons/meshes for the neurons
  - The aim here is to plot the FAFB and malecns neurons you ran cosine clustering analysis on in the same space - dependng on your preference, you can plot the fafb neurons in malecns space, or vice versa. The malecns template of interest is 'JRCFIB2022M' (which is in nanometres - or 'JRCFIB2022Mraw' to have it in voxels).
      - For those of you using R, you will need the elmr library to transform from FAFB to other templates - you can search for existing brain templates using the functions listed here. I believe to transform from FAFB to malecns requires the following:
        
            xform_brain(neurons, sample = FAFB14, reference = "malecns")
        
      - For those of you using Python, you will need the navis-flybrains  package - you can search for existing brain templates using the function below. Here is a link to a tutorial/run through of how to perform brain transforms using Python, but be aware that the malecns templates have not been added to the schematic under the flybrains heading (in case you are looking for them).

            navis.transforms.registry.summary()
  
  - Once the neurons have been plotted in the same space, add the brain template; the fafb brain template can be accessed from the elmr package (along with nearly all other templates) and the malecns template is in the malecns  package and can be plotted by using the command below (in R).

            plot3d(malecns.surf, alpha=.1)

  - plot the malecns neurons in a green gradient colour scale: the cell type of interest is to be in the darkest green colour.
  - plot the FAFB neurons in a blue gradient colour scale: the cell type of interest is to be in the darkest blue colour.

