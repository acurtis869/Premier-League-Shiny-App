#ui.R

library(shiny)
fluidPage(
  
  # App name
  titlePanel("Premier League Table"),
  
  # Sidebar with options on how to sort, a refresh button and a download data
  # option
  sidebarLayout(
    
    sidebarPanel(
      # Sorting options
      selectInput("ordering", "Order by:",
                  choices = c("position, club, played, won, drawn, 
                              lost, GF, GA, GD, points")),
      # Refresh button
      actionButton(inputId = "refresh",
                   label = "Refresh Table",
                   icon = icon("sync")),
      # Download dataset button
      actionButton(inputId = "download",
                   label = "Download Dataset",
                   icon = icon("download"))
    ),
    # The main table
    mainPanel(plotOutput(outputId = "table"))
    )
)