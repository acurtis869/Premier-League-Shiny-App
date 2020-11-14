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


# init function -----------------------------------------------------------

getMarketValue <- function() {
  # Begin scraping
  URL <- "https://www.transfermarkt.com/premier-league/marktwerteverein/wettbewerb/GB1"
  htmlPage <- read_html(URL)
  
  value_raw <- htmlPage %>% 
    html_nodes(".rechts.hauptlink a") %>%
    html_text()
  value_raw <- value_raw[seq(2, 40, 2)] %>%
    str_remove("€")
  value <- rep(NA, length(value_raw))
  for (i in 1:length(value_raw)) {
    if (grepl("bn", value_raw[i])) {
      value_raw[i] <- str_remove(value_raw[i], "bn")
      value[i] <- as.numeric(value_raw[i])
      value[i] <- value[i] * 1000
    }
    else {
      value_raw[i] <- str_remove(value_raw[i], "m")
      value[i] <- as.numeric(value_raw[i])
    }
  } 
  
  club <- htmlPage %>%
    html_nodes(".no-border-links") %>%
    html_text() %>%
    str_remove(" FC") %>%
    str_replace("&", "and")
  
  MarketValue <- data.frame(club, value)
  return(MarketValue)
}


# Scrape all the Data -----------------------------------------------------


premTable <- getPremTable()
stadiumCoords <- getCoords()
stadiumCoords$latitude <- lapply(stadiumCoords$latitude, transformLatToDecimal)
stadiumCoords$longitude <- lapply(stadiumCoords$longitude, transformLongToDecimal)
marketValue <- getMarketValue()

# Merge all data together into one table ----------------------------------

premTable <-merge(premTable, marketValue, by = "club")
premData <- merge(premTable, marketValue, by = "club")

head(premData)
