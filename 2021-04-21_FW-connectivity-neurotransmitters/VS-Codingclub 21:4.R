#Varun Sane
#The code reads neurons from a lineage of the fafb_hemilineages_survey_right sheet, subsets by adequate and complete.
# Next, it predicts the neurotransmitter for those neurons. Then it gets the downstream partners of the neurons, determines their neurotransmitter identity
# and plots the distribution of the downstream partners for each neuron in the lineage. It also plots the distribution of weak and strong connections for each neuron.
#call packages
library(fafbseg)
library(natverse)
library(ggplot2)
library(googlesheets4)
library(hemibrainr)
library(data.table)
library(plotly)
#read LHp2 neurons fron surveysheet, subset by adequate, complete
lhp2neurons = read_sheet(
  "https://docs.google.com/spreadsheets/d/1QyuHFdqz705OSxXNynD9moIsLvZGjjBjylx5sGZP2Yg/edit#gid=1518366804",
  sheet = "ItoLee_Hemilineage_LHp2_lateral_right"
)
lhp2_ac_neurons = lhp2neurons[lhp2neurons$status == "adequate" |
                                lhp2neurons$status == "complete" |
                                lhp2neurons$status == "a" | lhp2neurons$status == "c", ]
lhp2_ac_neurons_id = flywire_latestid(lhp2_ac_neurons$flywire.id)#get latestid. can do this in lhp2_ac_neurons itself. separated for ease.
lhp2_nts = flywire_ntpred(lhp2_ac_neurons_id)#predict nts for adequate, complete neurons
lhp2_nts #general NT prediction for all neurons
top <-
  data.frame(table(lhp2_nts$top.nt) %>% sort(decreasing = T))$Var1[1]#top NT
message (
  "Main neurotransmitter for ItoLee_Hemilineage_",
  lhp2_ac_neurons$ItoLee_Hemilineage[1],
  "_",
  lhp2_ac_neurons$side[1],
  " is ",
  top
) #main neurotransmitter acetylcholine

#create ngl scene
fw_url = with_segmentation('flywire', getOption('fafbseg.sampleurl'))
colourdf = data.frame(lhp2_ac_neurons_id, col = "yellow")#can and should be done in a generalized manner
fw_sc = ngl_add_colours(fw_url, colourdf)
browseURL(as.character(fw_sc))

#plot in R
lhp2_ac_meshes <-
  read_cloudvolume_meshes(lhp2_ac_neurons_id)#read cloudvolume meshes
plot3d(lhp2_ac_meshes, col = "yellow")#plot in a given colour
plot3d(FAFB14, alpha = 0.3)#plot FAFB volume as well

# downstream_partners_lhp2=flywire_partners(lhp2_ac_neurons_id, partners = "out")#downstream partners of lhp2_lateral neurons
downstream_partners_lhp2_summary = flywire_partner_summary(lhp2_ac_neurons_id)#get downstream neuron summary. has a better structure to deal with upcoming tasks
top_downstream_lhp2_new = data.frame()#initialise emply dataframe

#create list with top 30 downstream partners of each LHp2 neuron
top_downstream_lhp2_new = lapply(unique(downstream_partners_lhp2_summary$query), function(x) {
  rbind(top_downstream_lhp2_new, as.data.frame(head(downstream_partners_lhp2_summary[downstream_partners_lhp2_summary$query ==
                                                                                       x, ], 30)))
})
top_downstream_lhp2_table_new = as.data.frame(rbindlist(top_downstream_lhp2_new))#transform list into dataframe. can be used in lapply itself, possibly.
top_downstream_lhp2_table_new$post_id = flywire_latestid(top_downstream_lhp2_table_new$post_id)#get latest id for each of the donwstream neurons

# top_downstream_ntpreds=data.frame()
metadata1 <- as.data.frame(flywire_meta())#get flywire metadata
top_downstream_lhp2_meta_new <-
  filter(metadata1,
         metadata1$flywire.id %in% top_downstream_lhp2_table_new$post_id)#get metadata for all donwstream partners
nts_down_table = as.data.frame(table(top_downstream_lhp2_meta_new$top.nt))#NT identities for all downstream neurons taken together

#get lhp2 neurons, their downstream partners and NT identity in one dataframe
a_new = merge(
  top_downstream_lhp2_table_new,
  top_downstream_lhp2_meta_new[c("flywire.id", "top.nt")],
  by.x = "post_id",
  by.y = "flywire.id"
)
table_a_new = as.data.frame(table(a_new$query, a_new$top.nt))#get NT of downstream data for each lhp2 neuron individually.

#custom colour code roughly based on ntpred colour scheme
nt_colour_code <-
  c(
    acetylcholine = "blue4",
    dopamine = "red3",
    gaba = "gold2",
    glutamate = "green4",
    serotonin = "purple",
    octopamine = "skyblue2",
    unknown = "grey66"
  )

#plot downstream partner summary by individual neurons. made using esquisse and ggplot theme assistant
ggplotobj_new = ggplot(table_a_new) +
  aes(x = Var1, fill = Var2, weight = Freq) +
  geom_bar() + scale_fill_hue() + labs(x = "Neurons") +
  coord_flip() + theme_minimal() +  theme(legend.position = "top")
ggplotobj_new = ggplotobj_new + theme(
  axis.title = element_text(size = 15, face = "bold"),
  axis.text = element_text(face = "bold"),
  axis.text.y = element_text(size = 12),
  plot.title = element_text(face = "bold"),
  legend.title = element_text(face = "bold"),
  legend.direction = "horizontal"
) + labs(y = "Count", fill = "Neurotransmitter") + scale_fill_manual(values = nt_colour_code)
ggplotobj_new
# ggplotly(ggplotobj) #interactive plot if needed


#plot downstream partner summary overall

ggplot_overall = ggplot(nts_down_table) +
  aes(x = Var1, weight = Freq) +
  geom_bar(fill = "#0c4c8a") +
  theme_minimal() + theme(
    axis.title = element_text(size = 15,
                              face = "bold"),
    axis.text = element_text(face = "bold"),
    axis.text.x = element_text(size = 12),
    axis.text.y = element_text(size = 12)
  ) + labs(x = "Neurotransmitter", y = "Count")
ggplot_overall


lhp2_meta <-
  filter(metadata1, metadata1$flywire.id %in% lhp2_ac_neurons_id)#get metadata for lhp2 neurons

# downstream_partners_lhp2_summary= flywire_partner_summary(lhp2_ac_neurons_id)#get downstream neuron summary. has a better structure to deal with upcoming tasks
no_connections_downstream_partners_lhp2 = as.data.frame(table(downstream_partners_lhp2_summary$query))#find no of connections for each lhp2 neuron
#threshold for strong/weak connections for each neuron. 1% of total
no_connections_downstream_partners_lhp2$threshold = 0.01 * no_connections_downstream_partners_lhp2$Freq
df_final <- data.frame()#initialise dataframe

#iterate over all lhp2 neurons, get category for the connections they make with their partners
for (id in no_connections_downstream_partners_lhp2$Var1) {
  df = filter(downstream_partners_lhp2_summary, query == id)
  df$category <-
    ifelse(df$weight < no_connections_downstream_partners_lhp2$threshold[no_connections_downstream_partners_lhp2$Var1 ==
                                                                           id],
           "Weak",
           "Strong")
  df_final = rbind(df_final, df)
}
#get the no of strong and weak connections for each LHp2 neuron
lhp2_connection_stats <-
  as.data.frame(table(df_final$query, df_final$category))

ggplot_connections = ggplot(lhp2_connection_stats) +
  aes(x = Var1, fill = Var2, weight = Freq) +
  geom_bar() +
  scale_fill_hue() +
  labs(x = "Neurons", y = "Count", fill = "Connection type (Th = 1% of total connections)") +
  coord_flip() +  theme_minimal() + theme(
    axis.title = element_text(size = 14, face = "bold"),
    axis.text = element_text(size = 12, face = "bold"),
    axis.text.x = element_text(size = 12),
    axis.text.y = element_text(size = 12),
    legend.text = element_text(face = "bold"),
    legend.title = element_text(face = "bold")
  ) + labs(fill = "Connection type
(Threshold = 1% of total connections)")

# ggplotly(ggplot_connections)
ggplot_connections
