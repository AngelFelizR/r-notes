library(shiny)

ui <- fluidPage(
  dataTableOutput("table")
)
server <- function(input, output, session) {
  output$table <- renderDataTable(
    mtcars,
    options = list(
      pageLength = 5,
      searching = FALSE,
      ordering = FALSE
    )
  )
}

#Run
shinyApp(ui, server)
