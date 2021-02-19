library(catmaid)
library(tidyverse)

#Get all the neurons connected to Flywalkies
fw.conn = catmaid_query_connected(32793)

# gather neurons per group
upn =catmaid_skids("^WTPN2017_uPN$")
mpn =catmaid_skids("^WTPN2017_mPN$")
# anything that matches this but can have additional endings
mbon =catmaid_skids("^GI_MBON.*")

# take incoming connections and add type column
# exclude those with only 1 synapse
# count number of partners per type
# calculate percentages
fw.conn$incoming %>%
  mutate(type = case_when(
    partner%in%upn ~ "uPN",
    partner%in%mpn ~ "mPN",
    partner%in%mbon ~ "MBON",
    TRUE ~ "other"
  )) %>%
  filter(syn.count > 1) %>%
  count(type, name = "n.type") %>%
 mutate(pct=paste0(round(n.type/sum(n.type)*100, 2), "%")) -> fw.conn.summ
 
# to look at tibble (in essence a df), use View, str, or glimpse
