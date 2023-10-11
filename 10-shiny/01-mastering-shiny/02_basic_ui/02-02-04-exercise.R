library(shiny)


quarter_list <-
  matrix(month.name, ncol = 4) |>
  (\(M) lapply(1:ncol(M),\(y) M[,y]))()

names(quarter_list) <- paste0("Q",1:4)

ui <- fluidPage(
  selectInput(
    "month_name",
    "Select a month",
    choices = quarter_list
  )
)

server <- function(input, output, session){
}

#Run
shinyApp(ui, server)
