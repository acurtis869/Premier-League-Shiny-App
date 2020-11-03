#ui.R

library(shiny)
library(tidyverse)
library(rvest)

# Check we're allowed to scrape
library(robotstxt)
paths_allowed("https://www.premierleague.com/tables")

# Load in the web page:
URL <- "https://www.premierleague.com/tables"
htmlPage <- read_html(URL)

# Access the table:
position <- 1:20

club <- htmlPage %>% 
  html_nodes(".isPL .long") %>%
  html_text()

played <- htmlPage %>% 
  html_nodes(".isPL .team+ td") %>%
  html_text() %>%
  as.numeric()

won <- htmlPage %>%
  html_nodes(".isPL td:nth-child(5)") %>%
  html_text() %>%
  as.numeric()

drawn <- htmlPage %>%
  html_nodes(".isPL td:nth-child(6)") %>%
  html_text() %>%
  as.numeric()

lost <- htmlPage %>%
  html_nodes(".isPL td:nth-child(6)") %>%
  html_text() %>%
  as.numeric()

GF <- htmlPage %>%
  html_nodes(".isPL .hideSmall:nth-child(8)") %>%
  html_text() %>%
  as.numeric()

GA <- htmlPage %>%
  html_nodes(".isPL .hideSmall+ .hideSmall") %>%
  html_text() %>%
  as.numeric()

GD <- GF - GA

points <- htmlPage %>%
  html_nodes(".isPL .points") %>%
  html_text() %>%
  as.numeric()

fluidPage(
  
  # App name
  titlePanel("Premier League Table"),
  
  # Sidebar with options on how to sort, a refresh button and a download data
  # option
  sidebarLayout(
    
    sidebarPanel(
      # Sorting options
      selectInput("ordering", "Order by:",
                  choices = colnames(premTable)),
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


premTable <- data.frame(position, club, played, won, 
                        drawn, lost, GF, GA, GD, points)
premTable

attach(premTable)
premTable[order(GD, decreasing = TRUE),]

