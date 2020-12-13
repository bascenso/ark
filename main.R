
library(RCurl)
library(reshape2)
library(data.table)

#Variables
downloads_folder <- "downloads"  # Stores the files obtained from ARK
setwd("C:/Users/basce/OneDrive/11.GitRepos/ark")

## Load ARK fund holdings
file_ARKK <- getURL("https://ark-funds.com/wp-content/fundsiteliterature/csv/ARK_INNOVATION_ETF_ARKK_HOLDINGS.csv")
file_ARKF <- getURL("https://ark-funds.com/wp-content/fundsiteliterature/csv/ARK_FINTECH_INNOVATION_ETF_ARKF_HOLDINGS.csv")
file_ARKW <- getURL("https://ark-funds.com/wp-content/fundsiteliterature/csv/ARK_NEXT_GENERATION_INTERNET_ETF_ARKW_HOLDINGS.csv")
file_ARKG <- getURL("https://ark-funds.com/wp-content/fundsiteliterature/csv/ARK_GENOMIC_REVOLUTION_MULTISECTOR_ETF_ARKG_HOLDINGS.csv")
file_ARKQ <- getURL("https://ark-funds.com/wp-content/fundsiteliterature/csv/ARK_AUTONOMOUS_TECHNOLOGY_&_ROBOTICS_ETF_ARKQ_HOLDINGS.csv")

# Store files in folder 'downloaded' in format YYYY.MM.DD_ARKx.csv
if (file.exists(downloads_folder)) {

  name_prefix <- paste(gsub("-", ".", Sys.Date()), "ARK", sep = "_")

  con_ARKK <- file(paste(downloads_folder, "/", name_prefix, "K.csv", sep = ""))
  con_ARKF <- file(paste(downloads_folder, "/", name_prefix, "F.csv", sep = ""))
  con_ARKW <- file(paste(downloads_folder, "/", name_prefix, "W.csv", sep = ""))
  con_ARKG <- file(paste(downloads_folder, "/", name_prefix, "G.csv", sep = ""))
  con_ARKQ <- file(paste(downloads_folder, "/", name_prefix, "Q.csv", sep = ""))

  writeLines(file_ARKK, con_ARKK)
  writeLines(file_ARKF, con_ARKF)
  writeLines(file_ARKW, con_ARKW)
  writeLines(file_ARKG, con_ARKG)
  writeLines(file_ARKQ, con_ARKQ)

  close(con_ARKK)
  close(con_ARKF)
  close(con_ARKW)
  close(con_ARKG)
  close(con_ARKQ)
}


# Load files to data frames
DF_ARKK <- read.csv(text = file_ARKK)
DF_ARKF <- read.csv(text = file_ARKF)
DF_ARKW <- read.csv(text = file_ARKW)
DF_ARKG <- read.csv(text = file_ARKG)
DF_ARKQ <- read.csv(text = file_ARKQ)

# Trim final 3 lines (disclaimer) and merge into single DF
DF_ARKK <- DF_ARKK[1:(nrow(DF_ARKK) - 3), ]
DF_ARKF <- DF_ARKF[1:(nrow(DF_ARKF) - 3), ]
DF_ARKW <- DF_ARKW[1:(nrow(DF_ARKW) - 3), ]
DF_ARKG <- DF_ARKG[1:(nrow(DF_ARKG) - 3), ]
DF_ARKQ <- DF_ARKQ[1:(nrow(DF_ARKQ) - 3), ]

ARKholdings <- rbind(DF_ARKK, DF_ARKF, DF_ARKW, DF_ARKG, DF_ARKQ)


# Remove cusip column (useless) and improve column names
ARKholdings$cusip <- NULL
setnames(ARKholdings, "market.value...", "marketValue")
setnames(ARKholdings, "weight...", "weight")


# Merge with existing data and save
# PENDING


#Compute statistics
totals <- data.frame(value = tapply(ARKholdings$marketValue, ARKholdings$fund, sum))
totals <- totals[order(-totals$value), , drop = FALSE]

totalsEvolution <- reshape2::dcast(ARKholdings, fund ~ date, value.var = "marketValue", sum)

