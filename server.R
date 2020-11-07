# server.R
library(lubridate)

function(input, output) {
  # Scrape data from Premier League website
  source("getPremTable.R")
  premTable <- getPremTable()
  
  # Define our main output - a table
  output$table <- renderTable(
    arrange(premTable, 
            as.numeric(input$desc) * 
              dplyr::desc(!!rlang::sym(input$ordering))),
    digits = 0)
  
  output$time <- renderText({
    print(paste0("Table last updated at ", as_datetime(Sys.time())))
    })
  
  # Refresh table using the button
  observeEvent(input$refresh, {
    premTable <- getPremTable()
    output$table <- renderTable(
      arrange(premTable, 
              as.numeric(input$desc) * 
                dplyr::desc(!!rlang::sym(input$ordering))),
      digits = 0)
    
    output$time <- renderText({
      print(paste0("Table last updated at ", as_datetime(Sys.time())))
    })
  })
  
  # Download dataset button
  observeEvent(input$download, {
    write.csv(arrange(premTable, 
                      as.numeric(input$desc) * 
                        dplyr::desc(!!rlang::sym(input$ordering))),
              "Premier League Data.csv")
  })
}
