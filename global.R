#######################################################################
# This file calls the data scrapers, prepares the data, and passes it
# as plots to the shiny application.
#
# Imports: scarper functions
# 
# University of St Andrews, 2020
#######################################################################

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

# Generate Data and plots For Shiny Application --------------------------

getOutput <- function(input, output) {
  # Scrape data using scraping function above
  premTable <- getPremTable()
  stadiumCoords <- getCoords()
  stadiumCoords$latitude <- lapply(stadiumCoords$latitude, transformLatToDecimal)
  stadiumCoords$longitude <- lapply(stadiumCoords$longitude, transformLongToDecimal)
  
  # Merge all data together into one table ----------------------------------
  
  premData <- merge(premTable, stadiumCoords, by = "club")
  premData <- unnest(premData, cols = c(latitude, longitude))
  print(head(premData))
  # premData <- merge(premData, marketValue, by = "club")
  

# Table -------------------------------------------------------------------

  # Define our main output - a table
  output$table <- renderTable(
    arrange(premTable, 
            as.numeric(input$desc) * 
              dplyr::desc(!!rlang::sym(input$ordering))),
    digits = 0)
  

# Print Time Updated ------------------------------------------------------
  
  # Output the time of the last update
  output$time <- renderText({
    print(paste0("Table last updated at ", as_datetime(Sys.time())))
  })
  
# Scatter Plot ------------------------------------------------------------

  output$scatterPlot <- renderPlot({
    # create data frame
    df <- data.frame(premTable)
    # generate plot
    ggplot(df, aes_string(x = input$ordering, y = "points")) +
      geom_point() + 
      geom_smooth() +
      dark_theme_dark() +
      theme(plot.background = element_rect(fill = "#343E48", 
                                           colour = "#343E48"))
    },
    height = 400, width = 600)
  
# Map Content -------------------------------------------------------------

  # Prepare Data
  stadiums <- data.frame(
    lat = c(
      30.42106667,
      30.65395,
      31.62933333,
      31.6865,
      31.68715,
      31.64818333
    ), 
    long = c(9.022183333,
             8.180183333,
             8.100666667,
             8.109283333,
             8.110366667,
             8.104683333
    ),
    radius = c(1,20,3,10,5,50))
  
  # render Plot
  output$mymap <- renderLeaflet({
    leaflet(data = premData) %>%
      addProviderTiles(providers$OpenStreetMap,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addCircleMarkers(
        lat = premData$latitude, 
        lng = premData$longitude,
        radius = premData$position,
        color = ~ifelse(premData$position > 10, "green", "red"),
        label = premData$club
        )
  })
}
