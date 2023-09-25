library(shiny)

# UI
ui <- fluidPage(
  "Hello, world!"
)

# Server
server <- function(input, output, session) {
}

#Run
shinyApp(ui, server)
