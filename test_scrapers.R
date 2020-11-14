# Testing our scrapers

rm(list=ls()) # remove variables
dev.off() # clear graphics
cat("\014") # clear console

# Load required libraries -------------------------------------------------

library(ggdark)
library(lubridate) # for parsing premier league data.
# library(measurments) # for coordinates
library(tidyverse)
library(rvest)


# Load Required Scraper Functions -----------------------------------------

source("scraper/getPremTable.R")
source("scraper/getCoords.R")
source("scraper/getMarketValue.R")

# Scrape all the Data -----------------------------------------------------

# marketValue <- getMarketValue()
premTable <- getPremTable()
stadiumCoords <- getCoords()
stadiumCoords$latitude <- lapply(stadiumCoords$latitude, transformLatToDecimal)
stadiumCoords$longitude <- lapply(stadiumCoords$longitude, transformLongToDecimal)

# Merge all data together into one table ----------------------------------

premData <-merge(premTable, stadiumCoords, by = "club")
premData <- merge(premData, marketValue, by = "club")

long <- premData$longitude
premData1 <- unnest(premData, cols = c(latitude, longitude))
long1 <- premData1$longitude

long1[1]
