# 1. Intruction to Shiny

- [1.1. Basic Elements](#basic-elements)
- [1.2. Reactive expressions](#reactive-expressions)
- [1.3. Exercises](#exercises)

## 1.1. Basic Elements

To create a Shiny app you need follow the next steps:

- Define the **UI** with the `shiny::fluidPage` as the **layout
  function**, where we can add *input* and *output* controls which
  create plain **html**.
- Define server function with the arguments:
  - `input`: To get the user results
  - `outcome`: To assign **ID** to rendered results.
  - `session`
- Run all together in the `shiny::ShinyApp` function.

> **While shiny is running R is busy** and we can’t run new commands at
> the R console until the Shiny app stops.

Here is an simple example

``` r
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
```

## 1.2. Reactive expressions

The code `get(input$dataset, "package:datasets")` is duplicated and to
solve that problem we need to create a **reactive expression** as they
**only runs one time** until they **need** to be updated.

To create reactive expressions you just need to:

1.  Wrap your code in a `reactive({})` function.
2.  Save the result in a object
3.  Call the object as an **empty function**.

As you can see in the next example:

``` r
server <- function(input, output, session) {
  # Create a reactive expression
  dataset <- reactive({
    get(input$dataset, "package:datasets")
  })

  output$summary <- renderPrint({
    # Use a reactive expression by calling it like a function
    summary(dataset())
  })
  
  output$table <- renderTable({
    dataset()
  })
}
```

## 1.3. Exercises

1.  Create an app that greets the user by name. You don’t know all the
    functions you need to do this yet, so I’ve included some lines of
    code below. Think about which lines you’ll use and then copy and
    paste them into the right place in a Shiny app.

``` r
tableOutput("mortgage")
output$greeting <- renderText({
  paste0("Hello ", input$name)
})
numericInput("age", "How old are you?", value = NA)
textInput("name", "What's your name?")
textOutput("greeting")
output$histogram <- renderPlot({
  hist(rnorm(1000))
}, res = 96)
```

**Solution**

``` r
library(shiny)

ui <- fluidPage(
  textInput("name", "What's your name?"),
  textOutput("greeting")
)

server <- function(input, output, session){
  output$greeting <- renderText({
    paste0("Hello ", input$name)
  })
}

shinyApp(ui, server)
```

2.  Suppose your friend wants to design an app that allows the user to
    set a number(x) between 1 and 50, and displays the result of
    multiplying this number by 5. This is their first attempt, but
    unfortunately it has an error. Can you help them find and correct
    the error?

![](img/01-ex-x-times-5.png)

``` r
library(shiny)

ui <- fluidPage(
  sliderInput("x", label = "If x is", min = 1, max = 50, value = 30),
  "then x times 5 is",
  textOutput("product")
)

server <- function(input, output, session) {
  output$product <- renderText({ 
    x * 5
  })
}

shinyApp(ui, server)
```

**Solution**

He should have called `input$x` rather than only `x`.

``` r
library(shiny)

ui <- fluidPage(
  sliderInput("x", label = "If x is", min = 1, max = 50, value = 30),
  "then x times 5 is",
  textOutput("product")
)

server <- function(input, output, session) {
  output$product <- renderText({
    input$x * 5
  })
}

shinyApp(ui, server)
```

3.  Extend the app from the previous exercise to allow the user to set
    the value of the multiplier, y, so that the app yields the value of
    x \* y. The final result should look like this:

![](img/02-ex-x-times-y.png)

**Solution**

``` r
library(shiny)

ui <- fluidPage(
  sliderInput("x", label = "If x is", min = 1, max = 50, value = 30),
  sliderInput("y", label = "and y is", min = 1, max = 50, value = 5),
  "then x times y is",
  textOutput("product")
)

server <- function(input, output, session) {
  output$product <- renderText({
    input$x * input$y
  })
}

shinyApp(ui, server)
```

4.  Take the following app which adds some additional functionality to
    the last app described in the last exercise. What’s new? How could
    you reduce the amount of duplicated code in the app by using a
    reactive expression.

``` r
library(shiny)

ui <- fluidPage(
  sliderInput("x", "If x is", min = 1, max = 50, value = 30),
  sliderInput("y", "and y is", min = 1, max = 50, value = 5),
  "then, (x * y) is", textOutput("product"),
  "and, (x * y) + 5 is", textOutput("product_plus5"),
  "and (x * y) + 10 is", textOutput("product_plus10")
)

server <- function(input, output, session) {
  output$product <- renderText({ 
    product <- input$x * input$y
    product
  })
  output$product_plus5 <- renderText({ 
    product <- input$x * input$y
    product + 5
  })
  output$product_plus10 <- renderText({ 
    product <- input$x * input$y
    product + 10
  })
}

shinyApp(ui, server)
```

**Solution**

``` r
library(shiny)

ui <- fluidPage(
  sliderInput("x", "If x is", min = 1, max = 50, value = 30),
  sliderInput("y", "and y is", min = 1, max = 50, value = 5),
  "then, (x * y) is", textOutput("product"),
  "and, (x * y) + 5 is", textOutput("product_plus5"),
  "and (x * y) + 10 is", textOutput("product_plus10")
)

server <- function(input, output, session) {

  product <- reactive({
    input$x * input$y
  })

  output$product <- renderText({
    product()
  })
  output$product_plus5 <- renderText({
    product() + 5
  })
  output$product_plus10 <- renderText({
    product() + 10
  })
}

shinyApp(ui, server)
```

5.  The following app is very similar to one you’ve seen earlier in the
    chapter: you select a dataset from a package (this time we’re using
    the ggplot2 package) and the app prints out a summary and plot of
    the data. It also follows good practice and makes use of reactive
    expressions to avoid redundancy of code. However there are three
    bugs in the code provided below. Can you find and fix them?

``` r
library(shiny)
library(ggplot2)

datasets <- c("economics", "faithfuld", "seals")
ui <- fluidPage(
  selectInput("dataset", "Dataset", choices = datasets),
  verbatimTextOutput("summary"),
  tableOutput("plot")
)

server <- function(input, output, session) {
  dataset <- reactive({
    get(input$dataset, "package:ggplot2")
  })
  output$summmry <- renderPrint({
    summary(dataset())
  })
  output$plot <- renderPlot({
    plot(dataset)
  }, res = 96)
}

shinyApp(ui, server)
```

**Solution**

``` r
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
```