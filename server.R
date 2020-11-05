# server.R

function(input, output) {
  # Scrape data from Premier League website
  source("getPremTable.R")
  premTable <- getPremTable()
  
  # Define our only output - a table
  output$table <- renderTable(
    arrange(premTable, 
            as.numeric(input$desc) * dplyr::desc(!!rlang::sym(input$ordering))))
  
  # Download dataset button
  observeEvent(input$download, {
    write.csv(arrange(premTable, 
                      as.numeric(input$desc) * 
                        dplyr::desc(!!rlang::sym(input$ordering))),
    "Premier League Data.csv")
  })
}
