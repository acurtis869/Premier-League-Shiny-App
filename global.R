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


# Load Required Scraper Functions -----------------------------------------

source("scraper/getPremTable.R")
source("scraper/getCoords.R")
source("scraper/getMarketValue.R")

# Generate Data and plots For Shiny Application --------------------------

getOutput <- function(input, output) {
  # Scrape data using scraping function above
  premTable <- getPremTable()
  stadiumCoords <- getCoords()
  stadiumCoords$latitude <- lapply(stadiumCoords$latitude, transformLatToDecimal)
  stadiumCoords$longitude <- lapply(stadiumCoords$longitude, transformLongToDecimal)
  # marketValue <- getMarketValue()
  
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

  output$scatter <- renderPlot({
    # create data frame
    df <- data.frame(premTable)
    # generate plot
    ggplot(df, aes_string(x = input$xvar, y = input$yvar)) +
      geom_point() + 
      geom_smooth() +
      dark_theme_dark() +
      theme(plot.background = element_rect(fill = "#343E48", 
                                           colour = "#343E48")
            )
    },
    height = 400, width = 600)
  
# Map Content -------------------------------------------------------------

  # render map
  output$mymap <- renderLeaflet({
    # prep radius data
    premData$radiusValue = premData[[input$markerRadius]]
    # map
    leaflet(data = premData) %>%
      addProviderTiles(providers$OpenStreetMap,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addCircleMarkers(
        lat = ~latitude, 
        lng = ~longitude,
        radius = ~radiusValue,
        color = ~ifelse(radiusValue > input$colorSlider, "#044389", "#FFAD05"),
        label = premData$club
        )
  })


# Side Bar ----------------------------------------------------------------

  output$outSidebar <- renderUI({
    # my_ui_sidebar <- "Lorem Ipsum"
    if (input$tabset == "scatterplot") {
      print("scatterplot recognised")
      my_ui_sidebar <- 
        list(selectInput(inputId = "xvar",
                         label = "X Variable:",
                         choices = c("Position" = "position", 
                                     "Played" = "played", 
                                     "Won" = "won", 
                                     "Club" = "club", 
                                     "Drawn" = "drawn", 
                                     "Lost" = "lost",
                                     "GF" = "GF", 
                                     "GA" = "GA",
                                     "GD" = "GD",
                                     "Points" = "points")),
             selectInput(inputId = "yvar",
                         label = "Y Variable:",
                         choices = c("Position" = "position", 
                                     "Played" = "played",
                                     "Club" = "club", 
                                     "Won" = "won", 
                                     "Drawn" = "drawn", 
                                     "Lost" = "lost",
                                     "GF" = "GF", 
                                     "GA" = "GA",
                                     "GD" = "GD",
                                     "Points" = "points")))
    }
    if (input$tabset == "map") {
      print("map recognised")
      my_ui_sidebar <- 
        list(selectInput(inputId = "markerRadius",
                         label = "Marker Radius Variable:",
                         choices = c("Position" = "position", 
                                     "Played" = "played", 
                                     "Won" = "won", 
                                     "Drawn" = "drawn", 
                                     "Lost" = "lost",
                                     "GF" = "GF", 
                                     "GA" = "GA",
                                     "GD" = "GD",
                                     "Points" = "points")),
             sliderInput(inputId = "colorSlider", 
                         label = "Color Threshold:",
                         min = 0, 
                         max = 30,
                         value = 15)
        )
    }
    if (input$tabset == "table") {
      print("table recognised")
      my_ui_sidebar <- 
        list(selectInput(inputId = "ordering",
                    label = "Order by:",
                    choices = c("Position" = "position", 
                                "Club" = "club", 
                                "Played" = "played", 
                                "Won" = "won", 
                                "Drawn" = "drawn", 
                                "Lost" = "lost",
                                "GF" = "GF", 
                                "GA" = "GA",
                                "GD" = "GD",
                                "Points" = "points")),
      radioButtons(inputId = "desc",
                   label = "Direction",
                   choices = list("Ascending" = -1,
                                  "Descending" = 1)))   
    }
    return(my_ui_sidebar)
  })

# Close function ----------------------------------------------------------

}