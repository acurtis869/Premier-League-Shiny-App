# server.R
library(lubridate)

function(input, output) {
  # Create function (for modularity) which retrieves data and time and outputs
  # it in the correct format
  getData <- function() {
    # Scrape data using external function
    source("getPremTable.R")
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
  }
  # Retrive and output data using function above
  getData()

  
  # Refresh table using the button
  observeEvent(input$refresh, {
    # Output updated data using the function defined above
    getData()
  })
  
  # Download dataset button
  observeEvent(input$download, {
    write.csv(arrange(premTable, 
                      as.numeric(input$desc) * 
                        dplyr::desc(!!rlang::sym(input$ordering))),
              "Premier League Data.csv")
  })
}
