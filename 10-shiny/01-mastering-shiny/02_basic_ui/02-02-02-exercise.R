library(shiny)

ui <- fluidPage(
  sliderInput(
    "deliver_date",
    "When should we deliver?",
    min = as.Date("2020-09-16"),
    max = as.Date("2020-09-23"),
    value = as.Date("2020-09-17"))
)

server <- function(input, output, session){
}

#Run
shinyApp(ui, server)
