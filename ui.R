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
                   label = "Refresh Data",
                   icon = icon("sync")),
      # Download dataset button
      actionButton(inputId = "download",
                   label = "Download Dataset",
                   icon = icon("download")),
      # Time of last update text
      textOutput("time")
    ),
    # The main table
    mainPanel(
              # Output: Tabset
              tabsetPanel(type = "tabs",
                          tabPanel("Scatter Plot", plotOutput(outputId = "scatter_plot")),
                          tabPanel("Summary", verbatimTextOutput(outputId = "summary")),
                          tabPanel("Table", tableOutput(outputId = "table"))
              )
    )
  )
)