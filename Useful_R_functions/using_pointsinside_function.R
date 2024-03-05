da1pns=fetchn_fafb("name:PN glomerulus DA1", mirror=F, ref=JFRC2)
lhr=as.mesh3d(JFRC2NP.surf,'LH_R')
da1lh=nlapply(da1pns, function(x) subset(x, pointsinside(x,lhr, rval="logical")))
plot3d(da1lh)

