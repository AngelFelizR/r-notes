
# Libraries

library(shiny)
library(tidyverse)

download <- function(url,forder,name) {
  download.file(
    paste0(url, name),
    paste0(forder,"/", name),
    quiet = TRUE
  )
}


# Data

url_data <- "https://github.com/hadley/mastering-shiny/raw/main/neiss/"
folder_path <- "01-mastering-shiny/04_ER_injuries/neiss/"

# dir.create(folder_path)

# download(url_data, folder_path, "injuries.tsv.gz")
# download(url_data, folder_path, "population.tsv")
# download(url_data, folder_path, "products.tsv")

injuries <- vroom::vroom(file.path(folder_path, "injuries.tsv.gz"))
products <- vroom::vroom(file.path(folder_path, "products.tsv"))
population <- vroom::vroom(file.path(folder_path, "population.tsv"))


