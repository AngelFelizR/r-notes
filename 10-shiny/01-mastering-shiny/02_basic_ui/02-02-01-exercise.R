library(shiny)

ui <- fluidPage(
  textInput("name","Name", placeholder = "Your name")
)

server <- function(input, output, session){
}

#Run
shinyApp(ui, server)
