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
library(shinyalert)

dashboardPage(
  
  # App name
  dashboardHeader(title = "The Premier League"),
  
  # Sidebar with options on how to sort, a refresh button and a download data
  # option
  dashboardSidebar(
      
      # sidebar of each tabpanel
      uiOutput("outSidebar"),

      # Refresh button
      useShinyalert(),
      actionButton(inputId = "refresh",
                   label = "Refresh Data",
                   icon = icon("sync"),
                   width = "180px"),
      # Download dataset button
      actionButton(inputId = "download",
                   label = "Download Dataset",
                   icon = icon("download"),
                   width = "180px"),
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
          # use id to use input$tabset on server
          id = "tabset", 
          selected = "table",
          height = 12,
          width = 12,
          # panels
          tabPanel(value = "table", 
                   title = "Table",
                   h3("Overview of Premier League"),
                   tableOutput(outputId = "table")),
          tabPanel(
            value = "scatterplot",
            title = "Scatter Plot", 
            h3("Individual Variable Analysis"),
              plotOutput(outputId = "scatter")
            ),
          tabPanel(value = "map", 
                   title = "Map", 
                   h3("Geographic Analysis of Premier League Attributes"),
                   leafletOutput("mymap"),
                   p()
                   )
        )
      ),
      
      fluidRow(infoBoxOutput("tabsetSelected"))
    )
)
