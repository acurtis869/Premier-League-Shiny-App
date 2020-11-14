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
# source("scraper/getMarketValue.R") # importing this file breaks 
# the funciton. Reason unknown.

# init marketValue function ------------------------------------------------

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
  
  MarketValue <- data.frame("Club" = club, "Value" = value)
  return(MarketValue)
}


# Generate Data and plots For Shiny Application --------------------------

getOutput <- function(input, output) {
  # Scrape data using scraping function above
  premTable <- getPremTable()
  stadiumCoords <- getCoords()
  stadiumCoords$latitude <- lapply(stadiumCoords$latitude, transformLatToDecimal)
  stadiumCoords$longitude <- lapply(stadiumCoords$longitude, transformLongToDecimal)
  marketValue <- getMarketValue()
  
  # Merge all data together into one table ----------------------------------
  
  premTable <- merge(premTable, marketValue, by = "Club")
  premData <- merge(premTable, stadiumCoords, by = "Club")
  premData <- unnest(premData, cols = c(latitude, longitude))
  print(head(premTable))

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
            ) +
      ggtitle(paste0("Scatter Plot of ", input$xvar, " and ", input$yvar))
    }, height = 400, width = 600)
  
# Map Content -------------------------------------------------------------

  # render map
  output$mymap <- renderLeaflet({
    # prep radius data
    premData$radiusValue = premData[[input$markerRadius]]
    if (input$markerRadius == "value") {
      premData$radiusValue = premData[[input$markerRadius]]/100
    }
    # map
    leaflet(data = premData) %>%
      addProviderTiles(providers$OpenStreetMap,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addCircleMarkers(
        lat = ~latitude, 
        lng = ~longitude,
        radius = ~radiusValue,
        color = ~ifelse(radiusValue > input$colorSlider, 
                        "#044389", 
                        "#FFAD05"),
        label = premData$club
        )
  })

# Side Bar ----------------------------------------------------------------

  output$outSidebar <- renderUI({
    if (input$tabset == "scatterplot") {
      print("scatterplot recognised")
      my_ui_sidebar <- 
        list(selectInput(inputId = "xvar",
                         label = "X Variable:",
                         choices = c("Position" = "Position", 
                                     "Played" = "Played",
                                     "Club" = "Club", 
                                     "Won" = "Won", 
                                     "Drawn" = "Drawn", 
                                     "Lost" = "Lost",
                                     "Goals For" = "GF", 
                                     "Goals Against" = "GA",
                                     "Goal Difference" = "GD",
                                     "Points" = "Points",
                                     "Market Value" = "Value")),
             selectInput(inputId = "yvar",
                         label = "Y Variable:",
                         choices = c("Position" = "Position", 
                                     "Played" = "Played",
                                     "Club" = "Club", 
                                     "Won" = "Won", 
                                     "Drawn" = "Drawn", 
                                     "Lost" = "Lost",
                                     "Goals For" = "GF", 
                                     "Goals Against" = "GA",
                                     "Goal Difference" = "GD",
                                     "Points" = "Points",
                                     "Market Value" = "Value")))
    }
    if (input$tabset == "map") {
      print("map recognised")
      my_ui_sidebar <- 
        list(selectInput(inputId = "markerRadius",
                         label = "Marker Radius Variable:",
                         choices = c("Position" = "Position", 
                                     "Played" = "Played", 
                                     "Won" = "Won", 
                                     "Drawn" = "Drawn", 
                                     "Lost" = "Lost",
                                     "Goals For" = "GF", 
                                     "Goals Against" = "GA",
                                     "Goal Difference" = "GD",
                                     "Points" = "Points",
                                     "Market Value / 100" = "Value")),
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
                    choices = c("Position" = "Position", 
                                "Club" = "Club", 
                                "Played" = "Played", 
                                "Won" = "Won", 
                                "Drawn" = "Drawn", 
                                "Lost" = "Lost",
                                "Goals For" = "GF", 
                                "Goals Against" = "GA",
                                "Goal Difference" = "GD",
                                "Points" = "Points",
                                "Market Value" = "Value")),
      radioButtons(inputId = "desc",
                   label = "Direction",
                   choices = list("Ascending" = -1,
                                  "Descending" = 1)))   
    }
    return(my_ui_sidebar)
  })

# Close function ----------------------------------------------------------

}