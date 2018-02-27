#Questions for R club

#1)
allskids <-catmaid_skids("annotation:AJES_y5_upstream_SEZ")
mskids <-catmaid_skids("annotation:AJES_y5_upstream_SEZ")[c(2,5, 6, 7, 12)]

skids <- catmaid_skids("annotation:AJES_y5_upstream_SEZ")![c(2,5, 6, 7, 12)] 
#throws error, I wish to get everything that is not these skids

#Answer: Use ! for logical functions, to get actual values use minus sign.
allskids[-c(2,5, 6, 7, 12)]
