library(shiny)

ui <- fluidPage(
  sliderInput(
    "value",
    "Select a value",
    min = 0,
    max = 100,
    value = 0,
    step = 5,
    animate = TRUE)
)

server <- function(input, output, session){
}

#Run
shinyApp(ui, server)
