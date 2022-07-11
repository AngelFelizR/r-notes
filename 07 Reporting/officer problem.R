library(flextable)
library(officer)

example_ft <-
  data.frame(A = "Value", B = "Value" , C = "Value", D = "Value", F = "Value") |>
  flextable() |>
  border_remove() |>
  add_header_row(values = c("","BCD",""),
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
  print("C:/Users/anfeliz/Leasing/r-notes/07 Reporting/problem_example.pptx")

sessioninfo::session_info()

─ Session info ──────────────────────────────────────────────────────────────────────────────────────────────────
setting  value
version  R version 4.2.0 (2022-04-22 ucrt)
os       Windows 10 x64 (build 19043)
system   x86_64, mingw32
ui       RStudio
language (EN)
collate  English_United States.utf8
ctype    English_United States.utf8
tz       America/Caracas
date     2022-07-11
rstudio  2022.02.3+492 Prairie Trillium (desktop)
pandoc   2.17.1.1 @ C:/Program Files/RStudio/bin/quarto/bin/ (via rmarkdown)

─ Packages ──────────────────────────────────────────────────────────────────────────────────────────────────────
package     * version   date (UTC) lib source
base64enc     0.1-3     2015-07-28 [1] CRAN (R 4.2.0)
cli           3.3.0     2022-04-25 [1] CRAN (R 4.2.0)
data.table    1.14.2    2021-09-27 [1] CRAN (R 4.2.0)
digest        0.6.29    2021-12-01 [1] CRAN (R 4.2.0)
evaluate      0.15      2022-02-18 [1] CRAN (R 4.2.0)
fastmap       1.1.0     2021-01-25 [1] CRAN (R 4.2.0)
flextable   * 0.7.3.013 2022-07-11 [1] local
gdtools       0.2.4     2022-02-14 [1] CRAN (R 4.2.0)
htmltools     0.5.2     2021-08-25 [1] CRAN (R 4.2.0)
knitr         1.39      2022-04-26 [1] CRAN (R 4.2.0)
officer     * 0.4.4.001 2022-07-11 [1] local
R6            2.5.1     2021-08-19 [1] CRAN (R 4.2.0)
Rcpp          1.0.8.3   2022-03-17 [1] CRAN (R 4.2.0)
rlang         1.0.3     2022-06-27 [1] CRAN (R 4.2.1)
rmarkdown     2.14      2022-04-25 [1] CRAN (R 4.2.0)
rstudioapi    0.13      2020-11-12 [1] CRAN (R 4.2.0)
sessioninfo   1.2.2     2021-12-06 [1] CRAN (R 4.2.0)
systemfonts   1.0.4     2022-02-11 [1] CRAN (R 4.2.0)
uuid          1.1-0     2022-04-19 [1] CRAN (R 4.2.0)
xfun          0.31      2022-05-10 [1] CRAN (R 4.2.0)
xml2          1.3.3     2021-11-30 [1] CRAN (R 4.2.0)
zip           2.2.0     2021-05-31 [1] CRAN (R 4.2.0)

[1] C:/Users/anfeliz/AppData/Local/R/win-library/4.2
[2] C:/Program Files/R/R-4.2.0/library

