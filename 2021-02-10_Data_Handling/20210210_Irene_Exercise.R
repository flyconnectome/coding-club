upstream <- catmaid_get_connector_table(32793, direction = "incoming", partner.skids = TRUE, get_partner_nodes = TRUE)

upstream_partner_skid = unique(upstream$partner_skid[upstream$partner_nodes > 2])
upstream_partners = catmaid_skids(upstream_partner_skid)
uPN = catmaid_skids("annotation:WTPN2017_uPN$")
mPN = catmaid_skids("annotation:WTPN2017_mPN$")
allPNs = c(uPN, mPN)

others = subset(upstream, !(partner_skid %in% allPNs))
uPN_partners = subset(upstream, partner_skid %in% uPN)
mPN_partners = subset(upstream, partner_skid %in% mPN)

category_name = c("uPN", "mPN", "others")
uPN_number = length(unique(uPN_partners$partner_skid))
mPN_number = length(unique(mPN_partners$partner_skid))
others_number = length(unique(others$partner_skid))
upstream_number = length(unique(upstream$partner_skid))
category_percentage = c(uPN_number/upstream_number, mPN_number/upstream_number,others_number/upstream_number)
category_df = data.frame(category_name, category_percentage)

library(ggplot2)
bp <- ggplot(category_df, aes(x="", y=category_percentage, fill=category_name)) + geom_bar(width = 1, stat = "identity")
pie = bp + coord_polar("y", start=0)
pie