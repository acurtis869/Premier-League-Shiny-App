#ui.R

library(shiny)
library(dashboardthemes)
library(shinydashboard)
library(shinyjs)

dashboardPage(
  
  # App name
  dashboardHeader(title = "Premier League Table"
                  # theme = "blue_gradient"
                  ),
  
  # Sidebar with options on how to sort, a refresh button and a download data
  # option
  dashboardSidebar(
    
    # sidebarPanel(
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
      # todo make these side by side
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
    dashboardBody(
      shinyDashboardThemes(
        theme = "grey_dark"
      ),
      fluidRow(
        tabBox(
          title = NULL, width = 12,
          # use id to use input$tabset1 on server
          id = "tabset1", height = "250px",
          tabPanel("Scatter Plot", plotOutput(outputId = "scatterPlot")),
          tabPanel("Table Panel", tableOutput(outputId = "table")),
          tabPanel("Map", 
                   leafletOutput("mymap"),
                   p()
                   )
        )
      ),
      fluidRow(infoBoxOutput("tabset1Selected"))
    )
)
