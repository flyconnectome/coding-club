## *** The task ***
## 1. Plot 20 neurons using the annotations "Rclub_1807_Ex" and "Rclub_1807_In"
## 2. Colour these neurons by subset i.e. tract/ type
## 3. Plot neuropil volumes in such a way as to show the innervation sites of these neurons
## 4. Using one neuron ((1722886), differentially colour the post and postsynapses.
## 5. With the same neuron, differentially colour the axon and dendrite using tag 'axon' and 'dendrite'
## 6. (Optional) Colour the neuron by strahler order using RColorBrewer.



## ** Setup **
source("initRsession.R")
library("RColorBrewer")

## *** Setup for plotting ***
## To specify given viewpoint use par3d()$userMatrix when you have the view
frontViewMatrix=matrix(c(1,0,0,0,0,-1,0,0,0,0,-1,0,0,0,0,1),nrow=4,byrow=TRUE) # defines viewpoint
topViewMatrix=matrix(c(1,0,0,0,0,0,1,0,0,-1,0,0,0,0,0,1),nrow=4,byrow=TRUE) # defines viewpoint
backViewMatrix=matrix(c(-1,0,0,0,0,-1,0,0,0,0,1,0,0,0,0,1),nrow=4,byrow=TRUE) # defines Viewpoint
pushUp=matrix(c(0,0,0,0, 0,0,0,1000, 0,0,0,0, 0,0,0,0),nrow=4,byrow=TRUE) #add This to viewMatrix to Push neuron up
pushRight=matrix(c(0,0,0,1000, 0,0,0,0, 0,0,0,0, 0,0,0,0),nrow=4,byrow=TRUE) #add This to viewMatrix to Push neuron right

pictureWidth=640 # plot window/saved image size

AL_R=catmaid_get_volume("AL_R")
LH_R=catmaid_get_volume("LH_R")

## *** Read neurons from Catmaid ***
exNeurons=read.neurons.catmaid("annotation:Rclub_1807_Ex")
inNeurons=read.neurons.catmaid("annotation:Rclub_1807_In")
mPN=read.neuron.catmaid(1722886)



## *** Tasks 1-3 ***
if (rgl.cur()==0) {nopen3d()} #opens a new 3d plot window if there is none open
clear3d() #clears the 3d window
aspect3d(1,1,1) #sets the scale the same in all 3 directions
par3d(windowRect = 50 + c( 0, 0, pictureWidth, pictureWidth )) #window size
plot3d(exNeurons, WithConnectors=FALSE, soma = TRUE, col="cyan") #default for WithConnectors is FALSE, here present only to make it easy to change
plot3d(inNeurons, WithConnectors=FALSE, soma = TRUE, col="yellow")
shade3d(AL_R, col="white", alpha=0.4) # alpha=0: cant see
wire3d(AL_R, col="grey", alpha=0.6)
shade3d(LH_R, col="white", alpha=0.4) # alpha=0: cant see
wire3d(LH_R, col="grey", alpha=0.6)
rgl.bg(color="black") #default is white
rgl.viewpoint(userMatrix=backViewMatrix+5*pushUp-20*pushRight, zoom = 0.63)
#writeWebGL(dir="~/code/Plots/pres0606", width=500)
#rgl.snapshot(filename = "")



## *** Tasks 4-5 ***
## Getting axonal and dendritic subsets of mPN
axonindeces=distal_to(mPN,node.pointno=mPN$tags$'axon')
dendriteindeces=distal_to(mPN,node.pointno = mPN$tags$'dendrite')
backboneindeces=(1:(dim(mPN$d)[1]))[-c(axonindeces,dendriteindeces)]
axons=subset(mPN,axonindeces)
dendrites=subset(mPN,dendriteindeces)
backbone=subset(mPN,backboneindeces)

## Getting the soma to plot it
somaNode=mPN$tags$'soma'
somaIndex=grep(somaNode,mPN$d$PointNo)

## Plot
if (rgl.cur()==0) {nopen3d()} #opens a new 3d plot window if there is none open
clear3d() #clears the 3d window
aspect3d(1,1,1) #sets the scale the same in all 3 directions
par3d(windowRect = 50 + c( 0, 0, pictureWidth, pictureWidth )) #window size
plot3d(mPN, WithConnectors=TRUE, alpha=0) 
plot3d(axons, WithNodes=FALSE, col="yellow")
plot3d(dendrites, WithNodes=FALSE, col="green")
plot3d(backbone, WithNodes=FALSE, col="white")
plot3d(mPN$d$X[somaIndex], mPN$d$Y[somaIndex], mPN$d$Z[somaIndex], type='s', radius=2000, add=TRUE, col="white")
rgl.bg(color="black")
rgl.viewpoint(userMatrix=frontViewMatrix+25*pushUp-10*pushRight, zoom = 0.63)
#writeWebGL(dir="~/code/Plots/pres0606", width=500)
#rgl.snapshot(filename = "")



## *** Task 6 ***
mPNStrahlerOrder=(strahler_order(mPN))$points # create a list of the strahler orders of the nodes
colorPalette=rev(brewer.pal(n = max((mPNStrahlerOrder)), name = 'Blues'))

## Plot it with catmaid's 3dplot
if (rgl.cur()==0) {nopen3d()} #opens a new 3d plot window if there is none open
clear3d() #clears the 3d window
aspect3d(1,1,1) #sets the scale the same in all 3 directions
par3d(windowRect = 50 + c( 0, 0, pictureWidth, pictureWidth )) #window size
plot3d(mPN,alpha=0,WithNodes=FALSE) #
for (i in 1:max(mPNStrahlerOrder))
{
  plot3d(subset(mPN,mPNStrahlerOrder==i), col=colorPalette[i], alpha=1, WithNodes=FALSE, soma=TRUE)
}
plot3d(mPN$d$X[somaIndex], mPN$d$Y[somaIndex], mPN$d$Z[somaIndex], type='s', radius=2000, add=TRUE, col=colorPalette[mPNStrahlerOrder[somaIndex]])
rgl.bg(color="black") #default is white
rgl.viewpoint(userMatrix=frontViewMatrix+15*pushUp-10*pushRight, zoom=0.6)
#writeWebGL(dir="~/code/Plots/pres0606", width=500)
#rgl.snapshot(filename = "")

## Plot it as a scatterplot
#But actually just use the other one haha
if (rgl.cur()==0) {nopen3d()} #opens a new 3d plot window if there is none open
clear3d() #clears the 3d window
aspect3d(1,1,1) #sets the scale the same in all 3 directions
par3d(windowRect = 50 + c( 0, 0, pictureWidth, pictureWidth )) #window size
plot3d(mPN$d$X, mPN$d$Y, mPN$d$Z , col=colorPalette[mPNStrahlerOrder], alpha=1, size=0.01)
plot3d(mPN$d$X[somaIndex], mPN$d$Y[somaIndex], mPN$d$Z[somaIndex], type='s', radius=2000, add=TRUE, col=colorPalette[mPNStrahlerOrder[somaIndex]])
rgl.bg(color="black") #default is white
rgl.viewpoint(userMatrix=frontViewMatrix+15*pushUp-10*pushRight, zoom = 0.6)
#writeWebGL(dir="~/code/Plots/pres0606", width=500)
#rgl.snapshot(filename = "")
