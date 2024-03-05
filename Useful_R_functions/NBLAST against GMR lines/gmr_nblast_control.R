# Load NBLAST results
results = readRDS(file="y5upstream_2000nodesplus_VS_GMR.rds")
results_mirrored = readRDS(file="y5upstream_2000nodesplus_mirrored_VS_GMR.rds")
results_norm = readRDS(file="y5upstream_2000nodesplus_VS_GMR_norm.rds")
results_mirrored_norm = readRDS(file="y5upstream_2000nodesplus_mirrored_VS_GMR_norm.rds")
results_norm_alpha = readRDS(file="y5upstream_2000nodesplus_VS_GMR_norm_alpha.rds")
results_mirrored_norm_alpha = readRDS(file="y5upstream_2000nodesplus_mirrored_VS_GMR_norm_alpha.rds")
# Load skeletons
filtered_xformed = readRDS(file="y5upstream_2000nodesplus.rds")
filtered_mirrored = readRDS(file="y5upstream_2000nodesplus_mirrored.rds")

# Source required functions
source("gmr_scores.R")
source("plot_gmr_matches.R")

# Examples
SEZ1_gmr_matches = gmr_scores(annotation = "AJES_y5_sampled_SEZ1", resultsmat = results_norm)
plot_gmr_matches(SEZ1_gmr_matches,filtered_xformed)

SEZ1_gmr_matches_mir_alpha = gmr_scores(annotation = "AJES_y5_sampled_SEZ1", resultsmat = results_mirrored_norm_alpha)
plot_gmr_matches(SEZ1_gmr_matches_mir_alpha,filtered_mirrored)
