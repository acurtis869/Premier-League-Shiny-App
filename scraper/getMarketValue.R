#######################################################################
# This function scrapes the market value of premier league clubs
# 
# University of St Andrews, 2020
#######################################################################

# Load libraries
library(rvest)
library(tidyverse)

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

mergeTables <- function() {
  premTable <- getPremTable()
  MarketValue <- getMarketValue()
  
  merged <- merge(premTable, MarketValue)
  return(merged)
}