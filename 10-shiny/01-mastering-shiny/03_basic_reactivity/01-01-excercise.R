
library(shiny)

ui <- fluidPage(
  textInput("name", "What's your name?"),
  textOutput("greeting")
)

# From server to session
server1 <- function(input, output, session) {
  # From input$greeting to output$greeting
  # From name to input$name
  output$greeting <- renderText(paste0("Hello ", input$name))
}

shinyApp(ui, server1)


# From server to session
server2 <- function(input, output, session) {
  # We need to add a reactive function
  greeting <- reactive(paste0("Hello ", input$name))
  # We need a parenthesis to call a reactive expression
  output$greeting <- renderText(greeting())
}

shinyApp(ui, server2)


# From server to session
server3 <- function(input, output, session) {
  # we need to call a render function
  # From output$greting to output$greeting
  # Missing a space in function paste0
  output$greeting <- renderText(paste0("Hello ", input$name))
}

shinyApp(ui, server3)


