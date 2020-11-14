#######################################################################
# server.R
# 
# University of St Andrews, 2020
#######################################################################


function(input, output) {
  addClass(selector = 'body', class = 'sidebar-collapse') # collapse the sidebar
  
  # Create timer which triggers refresh every hour
  reload <- reactiveTimer(3.6e+6)
  # Code will rerun once timer reaches an hour
  observe({
    reload()
    # Retrive and output data using function in global.R
    getOutput(input, output)
  })
  
  # Refresh table using the button
  observeEvent(input$refresh, {
    # Output updated data using the function defined in global.R
    getOutput(input, output)
    shinyalert("Data Refreshed", paste0("The table was last updated at ", as_datetime(Sys.time())), type = "success")
  })
  
  # Download dataset button
  observeEvent(input$download, {
    write.csv(arrange(premTable, 
                      as.numeric(input$desc) * 
                        dplyr::desc(!!rlang::sym(input$ordering))),
              "Premier League Data.csv")
    shinyalert("Download Complete", "We saved the data to your shiny working directory.", type = "success")
  })
}
