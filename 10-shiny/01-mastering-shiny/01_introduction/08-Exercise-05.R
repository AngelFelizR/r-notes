
library(shiny)
library(ggplot2)

datasets <- c("economics", "faithfuld", "seals")

ui <- fluidPage(
  selectInput("dataset", "Dataset", choices = datasets),
  verbatimTextOutput("summary"),
  #1. The output is not a table
  plotOutput("plot")
)

server <- function(input, output, session) {
  dataset <- reactive({
    get(input$dataset, "package:ggplot2")
  })
  #2. The correct ID is summary rather than summmry
  output$summary <- renderPrint({
    summary(dataset())
  })
  output$plot <- renderPlot({
    #3. It was missing to call dataset as a function
    plot(dataset())
  }, res = 96)
}

shinyApp(ui, server)
