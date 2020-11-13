# Function which scrapes current data for the Premier League from online and
# returns the table as a data frame

# Load required libraries
library(tidyverse)
library(rvest)
library(ggdark)

getPremTable <- function() {
  # Begin scraping
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
  
  # Compile data into a data frame
  premTable <- data.frame(position, club, played, won, 
                          drawn, lost, GF, GA, GD, points)
  
  return(premTable)
}

# Function created for modularity which defines the ouputs required in the 
# server.

# Load required library
library(lubridate)

getOutput <- function(input, output) {
  # Scrape data using scraping function above
  premTable <- getPremTable()
  # Define our main output - a table
  output$table <- renderTable(
    arrange(premTable, 
            as.numeric(input$desc) * 
              dplyr::desc(!!rlang::sym(input$ordering))),
    digits = 0)
  # Output the time of the last update
  output$time <- renderText({
    print(paste0("Table last updated at ", as_datetime(Sys.time())))
  })
  
  
  # Output the Scatter Plot
  output$scatterPlot <- renderPlot({
    # create data frame
    df <- data.frame(premTable)
    # generate plot
    ggplot(df, aes_string(x = input$ordering, y = "points")) +
      geom_point() + 
      geom_smooth() +
      dark_theme_dark() +
      theme(plot.background = element_rect(fill = "#343E48", colour = "#343E48"))
    })
}

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
  
  MarketValue <- data.frame(club, value)
  return(MarketValue)
}

mergeTables <- function() {
  premTable <- getPremTable()
  MarketValue <- getMarketValue()

  merged <- merge(premTable, MarketValue)
  return(merged)
}
