library(elmr)
library(catmaid)
library(geometry)

dl4 = read.neuron.catmaid(23829)
dl4.conn = connectors(dl4)
dl4.conn.xyz = xyzmatrix(dl4.conn)

library(tracerutils)
dl4.LH = split_neuron_local(23829, dl4$tags$SCHLEGEL_LH[[1]]) #split_neuron_local acting up; fine if run locally
dl4.LH.conn = dl4.LH$connectors #connectors() method not working; dl4.LH just showing up as List of 10 rather than neuron, although has 'neuron' class
dl4.LH.conn.xyz = xyzmatrix(dl4.LH.conn)

#-----CONVEX HULLS-----

dl4.conn.conhull = convhulln(dl4.conn.xyz)
dl4.conn.conhull.indices = c(t(dl4.conn.conhull))
dl4.conn.conhull.triangles = do.call(rbind, lapply(1:length(dl4.conn.conhull.indices), function(x){ dl4.conn[dl4.conn.conhull.indices[x], c("x", "y", "z")]}))
triangles3d(dl4.conn.conhull.triangles, col = "gray", alpha = 0.2)
points3d(dl4.conn.xyz, col = "darkgreen")
plot3d(dl4, col = "black", soma = T, WithNodes = F)

dl4.LH.conn.conhull = convhulln(dl4.LH.conn.xyz)
dl4.LH.conn.conhull.indices = c(t(dl4.LH.conn.conhull))
dl4.LH.conn.conhull.triangles = do.call(rbind, lapply(1:length(dl4.conn.conhull.indices), function(x){ dl4.LH.conn[dl4.LH.conn.conhull.indices[x], c("x", "y", "z")]}))

open3d()
triangles3d(dl4.LH.conn.conhull.triangles, col = "gray", alpha = 0.2)
points3d(dl4.LH.conn.xyz, col = "darkgreen")
plot3d(dl4.LH, col = "black", soma = T, WithNodes = F)


#-----ALPHA SHAPES-----


