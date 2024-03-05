#Plotting neurons in R

library(catmaid)
#read CATMAID neurons into R
n <- read.neuron.catmaid(6045462) 
class(n)
nlist <- read.neurons.catmaid(c(6045462, 6335520))
class(nlist)
class(nlist[[1]]) #use double square brackets to get neurons in list by index
nlist_eg_name <- read.neurons.catmaid("name:Salvia")
nlist_eg_annotations <- read.neurons.catmaid("annotation:NAMK_DANs_lin_SEZ") #returns neurons with annotations that contain "NAMK_DANs_lin_SEZ"
nlist_eg_annotation <- read.neurons.catmaid("annotation:^NAMK_DANs_lin_SEZ_01$") #only returns neurons with exact annotation "NAMK_DANs_lin_SEZ_01"

#Plot CATMAID neurons in rgl windows
nopen3d()
op <- structure(list(FOV = 30, userMatrix = structure(c(0.998838663101196,  #code Kimberly made to resize rgl window
                                                     -0.00085014256183058, 0.0481719076633453, 0, 0.00598131213337183, 
                                                     -0.989921271800995, -0.141492277383804, 0, 0.0478066727519035, 
                                                     0.141615957021713, -0.988766610622406, 0, 0, 0, 0, 1),
                                                   .Dim = c(4L, 4L)), scale = c(1, 1, 1), zoom = 0.545811593532562, 
                  windowRect = c(4L,45L, 780L, 620L)),
             .Names = c("FOV", "userMatrix", "scale", "zoom", "windowRect"))
par3d(op)
plot3d(n, soma = T, col = "black", WithConnectors = T) #basic plot function

#change size and colour of connectors
clear3d()
points3d(n$connectors[n$connectors$prepost == 0,][,c('x','y','z')],#prepost == 0 for presynapses, == 1 for postsynapses
         col = "darkolivegreen3",
         size = 5)
points3d(n$connectors[n$connectors$prepost == 1,][,c('x','y','z')],
         col = "darkorchid3",
         size = 5)
plot3d(n, col = "orange", soma = T, lwd = 3, alpha = 0.5) #lwd = line thickness, alpha = transparency

#change background color
bg3d("black")

#plot FAFB space
library(elmr)
plot3d(FAFB14.surf, col = "white", alpha = 0.2)
plot3d(FAFB14NP.surf, "SMP.R", col = "pink", alpha = 0.2)
FAFB14NP.surf$RegionList

#NB/ There are also other spaces to plot in, eg. NBLASTing is done in FCWB by default
# emlr package has fetchn_fafb function which works similarly to read.neurons.catmaid but in FCWB space. 
library(flycircuit)
nopen3d()
FCWBn <- fetchn_fafb(6045462, mirror = F)
plot3d(FCWBn, soma = T, col = "black")
plot3d(FCWBNP.surf, "SMP.R", col = "grey", alpha = 0.5)


#save as screenshot to file path
snapshot3d("/Users/aes/Desktop/snapshot.png")

#Itterate through neuronlist plotting each neuron in new rgl and saving as .png
plot_func <- function(index){
  nopen3d()
  clear3d()
  par3d(op)
  plot3d(FAFB14, col = "white", alpha = 0.1)
  plot3d(nlist[[index]], soma = T, col = "black", WithConnectors = T)
  snapshot3d(paste("/Users/aes/Desktop/", nlist[[index]]$skid ,".png", sep = ""))
  rgl.close()
}
lapply(1:2, plot_func)

