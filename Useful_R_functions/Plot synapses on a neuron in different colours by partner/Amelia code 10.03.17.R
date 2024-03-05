#Visualise synapses on a neuron of interest, where synapses are coloured differently for each different neuron connecting.
#With this function you give it the skid of your main interesting neuron,
#and 2 other skids upstream of your main neuron, the synapses it makes onto your neuron of interest will show in different colours.
#This is only for input synapses onto your neuron of interest.
#Problems:
#Only 2 skids, only incoming synapses, no ledgend.
#Tried to use an apply function but it didn't work. 
#Read neurons that you are interested in, firstly the main neuron then two neurons you want to view the synapses of...
main_neuron=read.neuron.catmaid()
n1=read.neuron.catmaid()
n2=read.neuron.catmaid()
synapses <- function(skid, pre.skid1, pre.skid2) {
  #get neuron of interest (skid)
  # catmaid_skids function allows you to pass in names or annotations - also checks that you only get one back
  skid=catmaid_skids(skid, several.ok = FALSE)
  neuron = read.neuron.catmaid(skid)
  neuron_data = catmaid_get_connectors_between(post_skids = skid)
  
  selected_pre_skids_1 <-neuron_data[neuron_data$pre_skid %in% pre.skid1,]
  selected_pre_skids_2 <-neuron_data[neuron_data$pre_skid %in% pre.skid2,]
  
  nopen3d()
  plot3d(neuron, soma=2000, col='Grey')
  points3d(selected_pre_skids_1[,c('connector_x','connector_y','connector_z')], col="dark green", size=7)
  points3d(selected_pre_skids_2[,c('connector_x','connector_y','connector_z')], col="purple", size=7)
  
}
