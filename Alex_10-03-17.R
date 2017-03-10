devtools::install_github("alexanderbates/catnat")
?synapsecolours.neuron

# Example
amadan = read.neuron.catmaid("name:Amadan") # Interesting LHON
synapsecolours.neuron(amadan,skids = c("346114","1420974","2152181"),printout=T) 

# See the guts of the function
synapsecolours.neuron