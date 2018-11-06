library(googlesheets)
#read list of neuron names sampled from google sheets
y5 <- gs_title("Upstream SMP (PAM-y5)")
data <- gs_read(ss = y5, ws = 3, range = "K3:K100")
neuron_name <- data$`Final Neuron Name`

#neurons upstream of sampled y5-PAM upstream neurons
neuron_name <- unlist(lapply(c(2:7), function(x) as.data.frame(gs_read(ss = y5, ws = x, range = "K3:K500"))[,1]))

###### Give function list of neuron names or skids and it will plot if it is a new neuron, an exisiting neuron, or a gap in the list (ie. a fragment) ####

sampling <- function(neuron_name){
#return a logical vector FALSE means it's a new neuron, TRUE means it's an existing neuron
logical_new_or_exisiting <- sapply(1:length(neuron_name), function(x) sum(neuron_name[c(1:x)] %in% neuron_name[x]) >= 2 )
#Indices of neuron_name at which a neuron has not been found and is empty in original list of neuronnames read in from googlesheet, ie. it is still a fragment
logical_new_or_exisiting[which(is.na(neuron_name))] <- NA 
#Make an empty data frame to make a cumulative count of whether it's a new or existing neuron, or a fragment
sum_up <- data.frame('Name' = neuron_name, 'Cumulative new neurons' = 0)
#If logical_new_or_exisiting is FALSE: new_neurs = new_neurs + 1,
#if TRUE: new_neurs = new_neurs, 
#if NA then insert a 0 as it is neither an existing neuron nor a new neuron (likely a fragment)
new_neurs <- 0
for (i in 1:length(logical_new_or_exisiting)) {
    if (FALSE %in% logical_new_or_exisiting[i]) {
      new_neurs = new_neurs + 1
      } else if(TRUE %in% logical_new_or_exisiting[index]) {
      new_neurs = new_neurs
  } else if(NA %in% logical_new_or_exisiting[index]){
      new_neurs = new_neurs
    }
  sum_up$Cumulative.new.neurons[index] <- new_neurs
}
for (index in 1:length(logical_new_or_exisiting)){   #ie. if it is a fragment 
  if (NA %in% sum_up$Name[index]){
    sum_up$Cumulative.new.neurons[index] <- 0
  }}
return(sum_up)
}

cumulative_count <- sampling(neuron_name)

#####plot of cumulative new neurons against profiles sampled ####
par(mar = c(5,5,5,5))
plot(1:nrow(cumulative_count), cumulative_count$Cumulative.new.neurons, xlab = list('Profiles sampled'), ylab = list('Number of Neurons'), 
     cex.lab=1.5, cex.axis=1.5, xlim=c(0,400),ylim=c(0,200), cex=0.7,
     pch = 19,
     col = color <- c(replicate(25, "red"),
                      replicate(69, "blue"), 
                      replicate(69, "orange"), 
                      replicate(69, "darkolivegreen4"), 
                      replicate(65, "magenta3"),
                      replicate(84, "mediumpurple3"),
                      replicate(101, "pink"))
     )
legend(1,200, c("PAM(5)", "PAM(6)", "PAM(7)", "PAM(13)", "PAM(17)", "PAM(1)", "PAM(10)"), c("red", "blue", "orange","darkolivegreen4", "magenta3", "mediumpurple3"))

