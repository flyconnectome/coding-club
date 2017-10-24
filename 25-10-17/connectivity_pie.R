#Takes Skid and returns pie charts of incoming and outgoing synaptic connections. Use syn_thresh to set the synapse threshold
#Other_thresh_in and Other_thresh_out sets the threshold for incoming and outgoing connections to be considered 'other'
library(catmaid)
library(plyr)
library(qcc)
library(plotly)
catmaid_login()

skid <- c(1775706)

connectivityPie <- function(skid, syn_thresh, other_thresh_in, other_thresh_out, pareto) {
  partners=catmaid_query_connected(skid, minimum_synapses = syn_thresh)
  
  #name them
  partners$incoming$partner <- catmaid_get_neuronnames(partners$incoming$partner)
  partners$outgoing$partner <- catmaid_get_neuronnames(partners$outgoing$partner)
  
  #Other_thresh sets the threshold number of synapses before being included in 'other' on the plot
  if (other_thresh_in > 0 | other_thresh_in > 0) {
    other_in <- c("NA", "other", sum((partners$incoming$syn.count < other_thresh_in)), "NA")  
    other_out <- c("NA", "other", sum((partners$outgoing$syn.count < other_thresh_out)), "NA")
  
    partners$incoming <- rbind(partners$incoming[partners$incoming$syn.count > other_thresh_in,], other_in)
    partners$outgoing <- rbind(partners$outgoing[partners$outgoing$syn.count > other_thresh_out,], other_out)
  }
  
  #Make numbers great again
  partners$outgoing$syn.count <- as.numeric(partners$outgoing$syn.count)
  partners$incoming$syn.count <- as.numeric(partners$incoming$syn.count)
  
  #Add percentages to names
  partners$incoming$partner <- paste(partners$incoming$partner,
                                     round(as.numeric(partners$incoming$syn.count)/sum(as.numeric(partners$incoming$syn.count))*100), "%"
                                     )
  partners$outgoing$partner <- paste(partners$outgoing$partner,
                                     round(as.numeric(partners$outgoing$syn.count)/sum(as.numeric(partners$outgoing$syn.count))*100), "%"
                                     )
  #Plot!
 if (pareto == TRUE) {
   #Pareto or no pareto, that is the question
   incoming <- partners$incoming$syn.count
   outgoing <- partners$outgoing$syn.count
   
   names(incoming) <- partners$incoming$partner
   names(outgoing) <- partners$outgoing$partner
   
   #Plot!
   par(mfrow=c(1,1))
   in_p <- pareto.chart(incoming, ylab = "Synapse Count", ylab2 = "Cumulative percentage", cumperc = seq(0, 100, by = 10),
                main = paste("Incoming synapses for", catmaid_get_neuronnames(skid))
                )
   out_p <- pareto.chart(outgoing, ylab = "Synapse Count", ylab2 = "Cumulative percentage", cumperc = seq(0, 100, by = 10), 
                main = paste("Incoming synapses for", catmaid_get_neuronnames(skid))
                )
 } else {
   par(mfrow=c(1,2))
   pie(partners$incoming$syn.count, labels = partners$incoming$partner, 
       main = paste("Incoming connections for:", catmaid_get_neuronnames(skid)), radius = 1.5, cex = 0.75
   )
   pie(partners$outgoing$syn.count, labels = partners$outgoing$partner,
       main = paste("Outgoing connections for:", catmaid_get_neuronnames(skid)), radius = 1.5, cex = 0.75
   )
 }
}


charts <- connectivityPie(skid, syn_thresh =  1, other_thresh_in = 3,
                          other_thresh_out = 6, pareto = FALSE
                          )
charts <- connectivityPie(skid, syn_thresh =  1, other_thresh_in = 3,
                          other_thresh_out = 6, pareto = TRUE
                          )
