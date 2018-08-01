# load libraries
library(dplyr)
library(elmr)
library(flycircuit)

# load gmrdps
gmrdps<-read.neuronlistfh("http://flybrain.mrc-lmb.cam.ac.uk/si/nblast/gmrdps/gmrdps.rds", localdir=getOption('flycircuit.datadir'), update=TRUE)

# change this to the directory where you have saved the files
setwd("/Users/flyconnectome/Desktop/KJH20180704")
