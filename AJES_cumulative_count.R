library(googlesheets)
#read list of neuron names sampled from google sheets
y5 <- gs_title("Upstream SMP (PAM-y5)")
data <- gs_read(ss = y5, ws = 2, range = "K3:K100")
neuron_name <- data$`Final Neuron ID`

#sampled y5-PAM upstream neurons
neuron_name <- unlist(lapply(c(2:6,8), function(x) as.data.frame(gs_read(ss = y5, ws = x, range = "K3:K100"))[,1]))

###### Give function list of neuron names or skids and it will plot if it is a new neuron, an exisiting neuron, or a gap in the list (ie. a fragment) ####

sampling <- function(neuron_name){
logical_new_or_exisiting <- unlist(lapply(1:length(neuron_name), function(x) length(which(neuron_name[c(1:x)] %in% neuron_name[x])) >= 2 )) #FALSE means it's a new neuron, TRUE means it's an existing neuron
logical_new_or_exisiting[which(neuron_name %in% NA)] <- NA #Indices of neuron_name at which a neuron has not been found, ie. it is a fragment
#If FALSE new_neurons = new_neurons + 1, if TRUE new_neurons = new_neurons, if NA fragments = fragments + 1

sum_up <- data.frame('Name' = neuron_name, 'Cumulative new neurons' = rep(0,length(neuron_name)))
new_neurs <- 0

for (index in 1:length(logical_new_or_exisiting)) {
    if (FALSE %in% logical_new_or_exisiting[index]) {
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
plot(1:nrow(cumulative_count), cumulative_count$Cumulative.new.neurons, xlab = list('Profiles sampled'), ylab = list('Number of Neurons'), 
     cex.lab=1.5, cex.axis=1.5, xlim=c(0,350),ylim=c(0,150), cex=0.7,
     pch = 19,
     col = color <- c(replicate(25, "red"),
                      replicate(69, "blue"), 
                      replicate(38, "orange"), 
                      replicate(69, "darkolivegreen4"), 
                      replicate(65, "magenta3"),
                      replicate(84, "mediumpurple3"))
     )
legend(300,75, c("PAM(5)", "PAM(6)", "PAM(7)", "PAM(13)", "PAM(17)", "PAM(1)"), c("red", "blue", "orange","darkolivegreen4", "magenta3", "mediumpurple3"))

