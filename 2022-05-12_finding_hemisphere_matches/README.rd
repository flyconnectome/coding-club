L/R matches prompt; 

- select singleton/cell-type matches across 2 hemispheres of your choice;
    - you can find many 1-1 matches here: https://flytable.mrc-lmb.cam.ac.uk/workspace/5/dtable/flywire_matching/?tid=Nscg&vid=0000. In R, you can get the table with one of these functions here (https://natverse.org/fafbseg/reference/index.html#flywire-annotations). In python you can use Philipp’s sea-serpent to access seatable.
    - ask for their up/downstream partners;
    - threshold so you have about hundreds of neurons;
    - get their l2 skeletons (maybe there’s hemibrain neuron skeletons somewhere already? For FAFB neurons, if you are coding in R, use fafbseg::read_l2skel(); the old way of getting skeletons: is to copy the ids from R, go to python to get the l2 skeletons, download the skeletons, and then read them into R (Python code for l2 skeletons at end of this prompt));
    - transform /mirror (mirror_fafb()in package nat.jrcbrains) half of the skeletons - if you compare between hemibrain and FAFB neurons, then you want to transform e.g. hemibrain neurons into FAFB space; if you compare between LR of FAFB, then you mirror neurons.
    - nblast (packages nat and nat.nblast in R, fafbseg and navis in python) and cluster into dendrogram (useful article here (https://natverse.org/nat.nblast/articles/NBLAST-Clustering.html); you may want to plot the dendrogram with nodes coloured by side (see one way to do this here)
    - find a cutting height of dendrogram to generate more cross hemisphere matches; To check matches:
    - one can check how mixed the colours are on the dendrogram, to see if neurons from different hemispheres can be put into the same group;
    - one can plot in flywire which has a hemibrain neuron layer
    - one can plot neurons / skeletons in R/Python together, coloured by hemisphere, to see if they match. To do this, in R you need plot3d() or plot3d in python.
    - record matches in flywire_matching (manual, could get e.g. 10 matches. Please only record 1-1 matches on flywire_matching, by pasting the coordinates in the hemisphere_match_xyz column. 
    - compare e.g. number of synapses with the original match. For example, if your original neurons were a_L and a_R, and they are connected to b_L and b_R, respectively. You want to ask if the number of synapses between a_L and b_L is similar to a_R and b_R, for all the matches you found. If, among your 10 matches, there are cell-type level matches where you have multiple sister cells of the same type on the same side, you may want to 1) record them elsewhere for the time being; and 2) group them together as a ‘meta-neuron’ for synapse counting.


Python code for l2 skeletons: 
import navis as ns
import skeletor as sk
import pandas as pd

from tqdm.auto import tqdm
from fafbseg import flywire

from navis.interfaces import r
from cloudvolume import CloudVolume

import numpy as np
# if you get your ids from a column in a spreadsheet 
ids = pd.read_clipboard(header=None)
ids = np.asarray(ids)
ids[0:5]
l2_sk = flywire.l2_skeleton(ids)
l2_sk.head()
for n in l2_sk:
   n.nodes['radius'] = 0
ns.write_swc(l2_sk, '/Users/yijieyin/Downloads/DM2_CX')
