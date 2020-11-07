# server.R
library(lubridate)

function(input, output) {
  # Create function (for modularity) which retrieves data and time and outputs
  # it in the correct format
  getOutput <- function() {
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
  
  # Create timer which triggers refresh every hour
  reload <- reactiveTimer(3.6e+6)
  # Code will rerun once timer reaches an hour
  observe({
    reload()
    # Retrive and output data using function above
    getOutput()
  })
  
  # Refresh table using the button
  observeEvent(input$refresh, {
    # Output updated data using the function defined above
    getOutput()
  })
  
  # Download dataset button
  observeEvent(input$download, {
    write.csv(arrange(premTable, 
                      as.numeric(input$desc) * 
                        dplyr::desc(!!rlang::sym(input$ordering))),
              "Premier League Data.csv")
  })
}
