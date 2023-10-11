library(shiny)
library(reactable)

ui <- fluidPage(
  reactableOutput("table")
)

server <- function(input, output) {
  output$table <- renderReactable({
    reactable(mtcars,
              defaultPageSize = 5)
  })
}

shinyApp(ui, server)
