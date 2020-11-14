#######################################################################
# This file contains the coordinate data scraping function.
# 
# University of St Andrews, 2020
#######################################################################
library(sp)
library(biogeo) # dms conversion

 getCoords <- function() {
  URL <- "https://en.wikipedia.org/wiki/List_of_Premier_League_stadiums#cite_note-14"
  htmlPage <- read_html(URL)
  
  club <- htmlPage %>%
    html_nodes("td:nth-child(3)") %>%
    html_text %>%
    str_replace("&", "and")
  
  latitude <- htmlPage %>%
    html_nodes(".latitude") %>%
    html_text
  
  longitude <- htmlPage %>%
    html_nodes(".longitude") %>%
    html_text
  
  coords <- data.frame("Club" = club, 
                       latitude, 
                       longitude)
  
  return(coords)
  
 }

transformLatToDecimal <- function(lat_string) {
  lat_list <- str_extract_all(lat_string, '\\d{0,3}', simplify = TRUE)
  lat <- dms2dd(as.numeric(lat_list[1]), as.numeric(lat_list[3]), as.numeric(lat_list[5]), "N")
  return(lat)
}

transformLongToDecimal <- function(lat_string) {
  lat_list <- str_extract_all(lat_string, '\\d{0,3}', simplify = TRUE)
  lat <- dms2dd(as.numeric(lat_list[1]), as.numeric(lat_list[3]), as.numeric(lat_list[5]), "W")
  return(lat)
}