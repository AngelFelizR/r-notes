library(flextable)
library(officer)

example_ft <-
  data.frame(A = "Value", B = "Value" , C = "Value", D = "Value", F = "Value") |>
  flextable() |>
  border_remove() |>
  add_header_row(values = c("","BC",""),
                 colwidths = c(1,3,1)) |>
  bold(part = "header") |>
  color(color = "white", part = "header") |>
  bg(bg = "#1F497D", part = "header") |>
  hline(i= 1, j= c(2,3,4),
        border = fp_border(color = "white"), 
        part = "header")

read_pptx() |>
  add_slide(layout = "Title and Content")  |>
  ph_with(example_ft, 
          location = ph_location_label(ph_label = "Content Placeholder 2") ) |>
  print("C:/Users/anfeliz/Leasing/r-notes/temp.pptx")

sessionInfo()
