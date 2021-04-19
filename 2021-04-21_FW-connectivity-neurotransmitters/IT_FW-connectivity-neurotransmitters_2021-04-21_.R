# Beginner:
#   get all the neurons in LHp2_lateral_right hemilineage and only filter those whose statuses are adequate or complete
# find the main neurotransmitter for that hl
# plot neurons in the hl, the neurons should be in different colours of your choice
# optional: create a ngl scene
# Intermediate:
#   find which neurotransmitter is expressed in each cell
# plot neurons in the hl, the neurons should be colour coded according to their neurotransmitters [example; all neurons expressing GABA plotted in blue, serotonin expressing neurons in yellow etc]
# Advanced:
#   get downstream connectivity for each neuron
# Plot the proportion of downstream targets that are GABA, Glut, etc. (recommended plot: boxplot)
# Plot number of weak and strong partners (where weak corresponds to <1% of target’s synapses accounted for by an upstream partner and strong is >= 1%) in axon and dendrites separately
# The exercise should be done considering the RHS only.

library(hemibrainr)
