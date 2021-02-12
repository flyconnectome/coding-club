library(fafbseg)
library(natverse)
library(ggplot2)
n=read.neurons.catmaid(skid=32793)#read catmaid neuron from skeleton id
npartner=catmaid_query_connected(32793)#find neurons connected to the queried neuron
str(npartner)
presynids=npartner$incoming$partner#obtain skids of upstream neurons

#doesnt yield correct results
# upns=presynids[which(catmaid_get_annotations_for_skeletons(presynids)$annotation=='WTPN2017_uPN')]
# mpns=presynids[which(catmaid_get_annotations_for_skeletons(presynids)$annotation=='WTPN2017_mPN')]
# mbons=presynids[which(catmaid_get_annotations_for_skeletons(presynids)$annotation=='GI_MBON')]
# otherns=setdiff(setdiff(setdiff(presynids,upns),mpns),mbons)

upns1= intersect(presynids,catmaid_skids("WTPN2017_uPN"))#check if any presynaptic neurons have any intersection with neurons annotated as uPNs. mPNs, or MBONs  
mpns1= intersect(presynids,catmaid_skids("WTPN2017_mPN"))
mbons1= intersect(presynids,catmaid_skids("GI_MBON"))
otherns1=setdiff(setdiff(setdiff(presynids,upns1),mpns1),mbons1)#find those that dont satify any of the above conditions

presynpartnersdf<-rbind(upns, mpns, mbons, otherns)#concatenate the different categories together.
# presynpartnersdf<-rbind(upns1, mpns1, mbons1, otherns1)

str(presynpartnersdf)


