# Function which gets current data for the Premier League from online

library(tidyverse)
library(rvest)

getPremTable <- function() {
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