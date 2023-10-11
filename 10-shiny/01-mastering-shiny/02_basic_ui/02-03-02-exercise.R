library(shiny)

ui <- fluidPage(
  plotOutput("plot", height = "300px", width = "700px")
)
server <- function(input, output, session) {
  output$plot <- renderPlot(
    plot(1:5),
    res = 96,
    alt = "Plotting 5 Random Numbers"
    )
}

#Run
shinyApp(ui, server)
