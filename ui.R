#######################################################################
# ui.R
# 
# University of St Andrews, 2020
#######################################################################

library(shiny)
library(dashboardthemes)
library(shinydashboard)
library(shinyjs)
library(leaflet) # map

dashboardPage(
  
  # App name
  dashboardHeader(title = "Premier League Table"),
  
  # Sidebar with options on how to sort, a refresh button and a download data
  # option
  dashboardSidebar(
      
      # sidebar of each tabpanel
      uiOutput("outSidebar"),

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
          title = NULL,
          # use id to use input$tabset1 on server
          id = "tabset", 
          selected = "table",
          height = 12,
          width = 12,
          # panels
          tabPanel(value = "table", 
                   title = "Table",
                   tableOutput(outputId = "table")),
          tabPanel(value = "scatterplot",
            title = "Scatter Plot", 
                   plotOutput(outputId = "scatter")),
          tabPanel(value = "map", 
                   title = "Map", 
                   leafletOutput("mymap"),
                   p()
                   )
        )
      ),
      
      fluidRow(infoBoxOutput("tabset1Selected"))
    )
)
