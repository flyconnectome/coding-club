# Basic1.FANCANs
 Basic manipulations of FANC AN data to see how the project is going

# Pull sheet into environment for up to date version to manipulate
library(googlesheets4)
AN_matching=googlesheets4::read_sheet(ss= '1GaLtEs-L-5wWWlDex93blmh6qlW1OprQqv_TLSSW9EI',
                                    sheet ="AN_proofreading")
# Create a table of completion status
status<-table(AN_matching[1:1864,10],useNA = "ifany")

# Create a barplot of completion status
barplot(status, main = "Proofreading status of ANs of FANC", xlab = "", ylab = "Number of Neurons", col = "lightblue", border = "black",ylim = c(0, 1500), beside = TRUE, las = 2)

# Create a table of contribution status
contribution<-table(AN_matching[1:1864,7],useNA = "ifany")

# Create a barplot of contribution status
barplot(contribution, main = "Contribution to proofreading of ANs of FANC", xlab = "", ylab = "Number of Neurons", col = "lightblue", border = "black",ylim = c(0, 1500), beside = TRUE, las = 2)

# Create a piechart of contribution status
pie(contribution, labels = rep("", length(contribution)),main = "Contribution to Proofreading of ANs of FANC", col = rainbow(length(contribution)))

# Turn tables into dataframes
Contribution<-data.frame(contribution)

# Turn rows/columns into vectors
Contributors<-c(Contribution[1, 1],Contribution[2, 1],Contribution[3, 1],Contribution[4, 1],Contribution[5, 1],Contribution[6, 1])
Contributors<-Contribution[,1]

# Add a legend
legend("bottomleft", legend = Contributors, fill = rainbow(length(contribution)), title = "Contributors", cex = 0.6, x.intersp = 0.3, y.intersp = 1)

# Create a table of confidence status
confidence<-c(AN_matching[1:1864,13],AN_matching[1:1864,7])
confidence<-table(confidence)

# Create a barplot of confidence of each contributor
colors <- c("lightblue", "blue", "darkblue")
barplot(confidence, main = "Confidence of proofreading of ANs of FANC", xlab = "", ylab = "Number of Neurons", col = colors, border = "black",ylim = c(0, 500), beside = TRUE, las = 2)

######################################################################################################################################################################################

# Extract NEW root IDs
fanc_match<-AN_matching[1:n,5]


# Make root ID into object
newrootID <- fanc_match$fanc_match[[n]]

# Pull up change log for root ID
fancr::fanc_change_log(newrootID)
 
 
# Turn new IDs into object
newID<-AN_matching[1:n,12]


# Has there been a change
changedNA <- ifelse(is.na(newID), FALSE, TRUE)
changed<-table(changedNA)

# Create a barplot of change
barplot(changed, main = "Neurons that have been changed", xlab = "", ylab = "Number of Neurons", col = colors, border = "black",ylim = c(0, 1500), beside = TRUE, las = 2)

# Load change log
change_log<-fancr::fanc_change_log("648518346500632501")

# Set variables
timestamp<-change_log[1:40,2]
contributor<-change_log[1:40,7]

# Load ggplot2 package
 library(ggplot2)
 
# Create timeline
 ggplot(change_log, aes(x = timestamp, y = contributor)) +
    geom_point(size = 5) +
    geom_line(size = 2) +
    labs(title = "Timeline", x = "Timestamp", y = "Contributor") +
    theme_minimal()
#####################################################################################################################################################################################


# Install the usethis package if you haven't already
# install.packages("usethis")

# Load the usethis package
library(usethis)

# Specify the raw GitHub URL of the file
github_url <- "https://raw.githubusercontent.com/boomstigmergy/Basic1.FANCANs/main/PrelimenaryFANCpractice.R?token=GHSAT0AAAAAACKKRQZSH2O3L64RPYCB5XSCZKU4EYQ"

# Specify the local file path where you want to save the file
local_file_path <- "PrelimenaryFANCpractice.R"

# Download the file
download.file(github_url, local_file_path, mode = "wb")

# trying URL 'https://raw.githubusercontent.com/boomstigmergy/Basic1.FANCANs/main/PrelimenaryFANCpractice.R?token=GHSAT0AAAAAACKKRQZSH2O3L64RPYCB5XSCZKU4EYQ'
#Content type 'text/plain; charset=utf-8' length 19596 bytes (19 KB)
==================================================
#downloaded 19 KB

# Specify the local file path
 local_file_path <- "PrelimenaryFANCpractice.R"

# Check if the file exists
file_exists <- file.exists(local_file_path)
 
# Print the result
 print(file_exists)
[1] TRUE

list.files()

# Specify the local file path
local_file_path <- "PrelimenaryFANCpractice.R"

# Read the entire content of the file
file_content <- readLines(local_file_path)

# Print the file content
cat(file_content, sep = "\n")