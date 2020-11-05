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
      selectInput(inputId = "ordering",
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
                                  "Descending" = 1)),
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
    mainPanel(tabPanel("Table"),
              tableOutput("table"))
    )
)