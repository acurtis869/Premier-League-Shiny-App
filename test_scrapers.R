# Testing our scrapers


# Load required libraries -------------------------------------------------

library(tidyverse)
library(rvest)
library(ggdark)
library(lubridate) # for parsing premier league data.
# library(measurments) # for coordinates


# Load Required Scraper Functions -----------------------------------------

source("scraper/getPremTable.R")
source("scraper/getMarketValue.R")
source("scraper/getCoords.R")

# Scrape all the Data -----------------------------------------------------

premTable <- getPremTable()
#marketValue <- getMarketValue()
stadiumCoords <- getCoords()
stadiumCoords$latitude <- lapply(stadiumCoords$latitude, transformLatToDecimal)
stadiumCoords$longitude <- lapply(stadiumCoords$longitude, transformLongToDecimal)

# Merge all data together into one table ----------------------------------

premData <-merge(premTable, stadiumCoords, by = "club")
# premData <- merge(premData, marketValue, by = "club")

long <- premData$longitude
premData1 <- unnest(premData, cols = c(latitude, longitude))
long1 <- premData1$longitude

long1[1]
