library(shiny)

# Setting up the basic visual structure (layout function)
# functions under this part only add html code
ui <- fluidPage(

  # Adding a Select Box (input control)
  selectInput(
    # Name for variable selected by the user
    "dataset",

    # Element title
    label = "Dataset",

    # List to display
    choices = ls("package:datasets")
  ),

  # Adding output controls to define where to put
  # the RENDERED output based on server output IDs
  # (output controls)
  verbatimTextOutput("TableSummary"), # displays code
  tableOutput("TableHead")           # displays tables

)


# Defining a function as server
server <- function(input, output, session) {

  # Assigning an ID for this output
  output$TableSummary <- renderPrint({

    # Making sure we are receiving the data
    # from the datasets package rather than
    # any other variable the global environment
    get(input$dataset, "package:datasets") |>
      # Rendering the printed value we want to report
      summary()

  })

  # Assigning an ID for this output
  output$TableHead <- renderTable({

    # Rendering the table we want to report
    get(input$dataset, "package:datasets") |>
      head()

  })
}

# Start the app
shinyApp(ui, server)
