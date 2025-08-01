# How to Import Any Spreadsheet File into `R`
Ángel Féliz
2023-10-17

## Introduction

**Do you struggle with importing complex or messy spreadsheets into
`R`?** You are not alone. Many data analysts and researchers face this
challenge every day.

Spreadsheets are widely used for storing, manipulating, and presenting
data in various domains and applications. However, ***not all
spreadsheets are created equal***. Some of them may contain multiple
tables, merged cells, headers, footers, comments, formulas, formatting,
or other features that make them difficult to import into `R` using
conventional packages like `readxl`, `openxlsx` or `openxlsx2`.

But don’t worry, there is a better way using `tidyxl` and `unpivotr`.
These two packages work together to handle any spreadsheet file, no
matter how it looks, in a fast and reproducible way.

- `tidyxl` imports every cell as a row, preserving all the information
  and attributes of the original file.

- `unpivotr` reshapes the data into a tidy format that is suitable for
  analysis and visualization.

In this blog post, **I will show you how to use these two packages to
import any spreadsheet file into `R` with ease and confidence** taking
your data analysis skills to the next level.

## Loading libraries

    [1] "R version 4.2.3 (2023-03-15 ucrt)"

``` r
# To import data
library(tidyxl)

# To transform the results
library(unpivotr)

# To print dir trees
library(fs)

# To explore results of tidyxl
library(data.table)

# To show interactive tables
library(reactable)
```

          Package Version Repository
    1:  reactable   0.4.4       CRAN
    2: data.table  1.14.8       CRAN
    3:         fs   1.6.3       CRAN
    4:   unpivotr   0.6.3       CRAN
    5:     tidyxl   1.0.8       <NA>

## Exploring results from tidyxl

To understand how to use this approach, we need to understand the
results of `xlsx_cells` column by column and how they relate to the
`xlsx_formats` results using different spreadsheet to ilustrate each
case.

### `tidyxl` example spreadsheet

``` r
ExampleSheetPath <- system.file(
  "extdata/examples.xlsx", 
  package = "tidyxl"
)

ExampleSheet <- xlsx_cells(ExampleSheetPath, sheets = "Sheet1")
ExampleSheetFormats <- xlsx_formats(ExampleSheetPath)

setDT(ExampleSheet)
setkey(ExampleSheet, address)
```

![extdata/examples.xlsx](img/02-many-cell-formats.png)

#### Cells’ position

- **sheet**: The worksheet that the cell is from.
- **address**: The cell address in A1 notation.
- **row**: The row number of a cell address (integer).
- **col**: The column number of a cell address (integer).

``` r
ExampleSheet[1:6, .(sheet,address, row, col)]
```

        sheet address row col
    1: Sheet1      A1   1   1
    2: Sheet1     A10  10   1
    3: Sheet1    A100 100   1
    4: Sheet1    A101 101   1
    5: Sheet1    A102 102   1
    6: Sheet1    A103 103   1

#### Cells’ content type

- **data_type**: The type of a cell, referring to the following columns:
  error, logical, numeric, date, character, blank.
- **is_blank**: It’s `TRUE` if the cell has a value.
- **content**: Raw cell value before type conversion. It may be:
  - A numeric value
  - A data/datetime in one of the Excel’s date/datetime systems.
  - An index into an internal table of strings.

``` r
ExampleSheet[, .SD[1:2],
             by = "data_type",
             .SDcols = c("is_blank", "content")]
```

        data_type is_blank             content
     1:     error    FALSE             #DIV/0!
     2:     error    FALSE              #NAME?
     3: character    FALSE                 107
     4: character    FALSE                 137
     5:   numeric    FALSE                   0
     6:   numeric    FALSE                   0
     7:      date    FALSE               42736
     8:      date    FALSE 0.35416666666666669
     9:     blank     TRUE                <NA>
    10:     blank     TRUE                <NA>
    11:   logical    FALSE                   1
    12:   logical    FALSE                   1

#### Cells’ content

- **error**: The error value of a cell.
- **logical**: The boolean value of a cell.
- **numeric**: The numeric value of a cell.
- **date**: The date value of a cell.
- **character**: The string value of a cell.
- **comment**: The text of a comment attached to a cell.

``` r
ValueCols <- c(
  "error",
  "character",
  "logical",
  "numeric",
  "date",
  "comment"
)

ExampleSheet[is_blank == FALSE, 
             .SD[order(is.na(comment))][1:2],
             by = "data_type",
             .SDcols = ValueCols]
```

        data_type   error                                               character
     1:     error #DIV/0!                                                    <NA>
     2:     error  #NAME?                                                    <NA>
     3: character    <NA>                                                 comment
     4: character    <NA> Data validation, list, in-cell dropdown, warning symbol
     5:   numeric    <NA>                                                    <NA>
     6:   numeric    <NA>                                                    <NA>
     7:      date    <NA>                                                    <NA>
     8:      date    <NA>                                                    <NA>
     9:   logical    <NA>                                                    <NA>
    10:   logical    <NA>                                                    <NA>
        logical numeric                date                   comment
     1:      NA      NA                <NA>                      <NA>
     2:      NA      NA                <NA>                      <NA>
     3:      NA      NA                <NA> commentwithtextformatting
     4:      NA      NA                <NA>                      <NA>
     5:      NA       0                <NA>                      <NA>
     6:      NA       0                <NA>                      <NA>
     7:      NA      NA 2017-01-01 00:00:00                      <NA>
     8:      NA      NA 1899-12-31 08:30:00                      <NA>
     9:    TRUE      NA                <NA>                      <NA>
    10:    TRUE      NA                <NA>                      <NA>

#### Cells’ formulas

![](img/05-example-formulas.png)

- **formula**: Shows as a text the formula used to return any value
  after removing braces `{}` for array functions.
- **formula_group**: When 2 cells has the same function or just changing
  by cell reference then Excel only the write the formula once in the
  document and `tidyxl`infers the group for those cases.
- **formula_ref**: The address of a range of cells group to which an
  **array** formula or **shared** formula applies.
- **is_array**: Whether or not the formula is an array formula. In
  `A22`the result is presented in the same cell, but for `A23` the
  result is displayed in cells `A23:A24`.

``` r
ExampleSheet[.(address = c(paste0("A",19:21),
                        paste0("B",19:21),
                        paste0("A",22:24))),
             .(address,
               formula,
               formula_group,
               formula_ref,
               is_array)]
```

       address              formula formula_group formula_ref is_array
    1:     A19              $A$18+1            NA        <NA>    FALSE
    2:     A20              $A$18+1             0     A20:A21    FALSE
    3:     A21              $A$18+1             0        <NA>    FALSE
    4:     B19                A18+2            NA        <NA>    FALSE
    5:     B20                A19+2             1     B20:B21    FALSE
    6:     B21                A20+2             1        <NA>    FALSE
    7:     A22 SUM(A19:A21*B19:B21)            NA         A22     TRUE
    8:     A23      A19:A20*B19:B20            NA     A23:A24     TRUE
    9:     A24                 <NA>            NA        <NA>    FALSE

#### Describing substrings’ formatting

- **character_formatted**: As a single cell can contain *substrings with
  different formatting*, each `character` cell has a `tibble` with one
  row per substring.

  - If a cell has many words but one format for all of them, this column
    will return a `tibble` with a single row, as we can see for cells
    `A108`, `A109`, `A112`, `A133` and `A134`, and if we unnest the
    columns we can only see `NA`.

``` r
SubstringsWithDefault <-
  ExampleSheet[.(address = paste0("A", c(108,109,112,133,134))), 
            .(address,
              character,
              character_formatted)]

SubstringsWithDefault
```

       address                                               character
    1:    A108 Data validation, list, in-cell dropdown, warning symbol
    2:    A109 Data validation, list, in-cell dropdown, warning symbol
    3:    A112                                               some text
    4:    A133                             underline single accounting
    5:    A134                             underline double accounting
       character_formatted
    1:      <tbl_df[1x14]>
    2:      <tbl_df[1x14]>
    3:      <tbl_df[1x14]>
    4:      <tbl_df[1x14]>
    5:      <tbl_df[1x14]>

``` r
SubstringsWithDefault[, character_formatted[[1L]],
                      by = "address"]
```

       address                                               character bold italic
    1:    A108 Data validation, list, in-cell dropdown, warning symbol   NA     NA
    2:    A109 Data validation, list, in-cell dropdown, warning symbol   NA     NA
    3:    A112                                               some text   NA     NA
    4:    A133                             underline single accounting   NA     NA
    5:    A134                             underline double accounting   NA     NA
       underline strike vertAlign size color_rgb color_theme color_indexed
    1:      <NA>     NA      <NA>   NA      <NA>          NA            NA
    2:      <NA>     NA      <NA>   NA      <NA>          NA            NA
    3:      <NA>     NA      <NA>   NA      <NA>          NA            NA
    4:      <NA>     NA      <NA>   NA      <NA>          NA            NA
    5:      <NA>     NA      <NA>   NA      <NA>          NA            NA
       color_tint font family scheme
    1:         NA <NA>     NA   <NA>
    2:         NA <NA>     NA   <NA>
    3:         NA <NA>     NA   <NA>
    4:         NA <NA>     NA   <NA>
    5:         NA <NA>     NA   <NA>

- But exploring the cell `A132` we can see how the `tibble` breaks the
  cell in **3 rows** representing different substring’s formats.

![](img/06-example-in-cell-text-format.png)

- - **in-cell** is *italic* and <span style="color:#0000ff"> blue
    </span>.
  - **format** is **bold** and <span style="color:#0000ff"> blue
    </span>.
  - **with cell-level defaults** is *italic* and
    <span style="color:#ff0000"> red </span>.

``` r
ExampleSheet[address == "A132", 
          as.data.table(character_formatted[[1L]])
# To avoid printing columns with a single value
][, .SD, .SDcols = \(x) uniqueN(x) > 1L]
```

                       character  bold italic color_rgb
    1:                  in-cell  FALSE   TRUE  FF0000FF
    2:                    format  TRUE  FALSE  FF0000FF
    3:  with cell-level defaults FALSE   TRUE  FFFF0000

#### Describing format ids

The next columns are related to the result of `xlsx_formats` which is a
nested list of formatting definitions from spreadsheets. With the next
code, we can print a tree until second level if the list. For example,
`cell-format$local$alignment` doesn’t have any other list bellow

``` r
create_folter_tree <- function(x, 
                               start_path,
                               show_properties = FALSE){
  
  if(!dir.exists(start_path)) dir.create(start_path)
  for(folder_i in names(x)){
    new_path <- file.path(start_path, folder_i)
    if(show_properties) dir.create(new_path)
    if(is.list(x[[folder_i]])){
      create_folter_tree(x[[folder_i]], new_path, show_properties)
    }
  }
  
}

start_path <- "cell-format"
create_folter_tree(ExampleSheetFormats, start_path, TRUE)
dir_tree(start_path, recurse = 2)
```

    cell-format
    ├── local
    │   ├── alignment
    │   │   ├── horizontal
    │   │   ├── indent
    │   │   ├── justifyLastLine
    │   │   ├── readingOrder
    │   │   ├── shrinkToFit
    │   │   ├── textRotation
    │   │   ├── vertical
    │   │   └── wrapText
    │   ├── border
    │   │   ├── bottom
    │   │   ├── diagonal
    │   │   ├── diagonalDown
    │   │   ├── diagonalUp
    │   │   ├── end
    │   │   ├── horizontal
    │   │   ├── left
    │   │   ├── outline
    │   │   ├── right
    │   │   ├── start
    │   │   ├── top
    │   │   └── vertical
    │   ├── fill
    │   │   ├── gradientFill
    │   │   └── patternFill
    │   ├── font
    │   │   ├── bold
    │   │   ├── color
    │   │   ├── family
    │   │   ├── italic
    │   │   ├── name
    │   │   ├── scheme
    │   │   ├── size
    │   │   ├── strike
    │   │   ├── underline
    │   │   └── vertAlign
    │   ├── numFmt
    │   └── protection
    │       ├── hidden
    │       └── locked
    └── style
        ├── alignment
        │   ├── horizontal
        │   ├── indent
        │   ├── justifyLastLine
        │   ├── readingOrder
        │   ├── shrinkToFit
        │   ├── textRotation
        │   ├── vertical
        │   └── wrapText
        ├── border
        │   ├── bottom
        │   ├── diagonal
        │   ├── diagonalDown
        │   ├── diagonalUp
        │   ├── end
        │   ├── horizontal
        │   ├── left
        │   ├── outline
        │   ├── right
        │   ├── start
        │   ├── top
        │   └── vertical
        ├── fill
        │   ├── gradientFill
        │   └── patternFill
        ├── font
        │   ├── bold
        │   ├── color
        │   ├── family
        │   ├── italic
        │   ├── name
        │   ├── scheme
        │   ├── size
        │   ├── strike
        │   ├── underline
        │   └── vertAlign
        ├── numFmt
        └── protection
            ├── hidden
            └── locked

``` r
unlink(start_path, recursive = TRUE)
```

- **style_format**: An index into a table of style formats
  `x$formats$style`. It is usually applied to blocks of cells, and
  defines several formats at once as we can see in next picture.

![](img/07-excel-styles.png)

- With this column we can find cells with bad style.

![](img/08-bad-style-cells.png)

``` r
ExampleSheet[style_format == "Bad",
             .(address,
               character,
               style_format)]
```

       address            character style_format
    1:     A31                  bad          Bad
    2:     A32 badboldrightupindent          Bad

- **local_format_id**: An index into a table of style formats
  `x$formats$local`. It is the more common kind and it is applied to
  individual cells. This cell can help the place the difference between
  `A31` and `A32` the second cell has the bold font local format.

``` r
ExampleSheet[style_format == "Bad" &
               local_format_id %in% which(ExampleSheetFormats$local$font$bold),
             .(address,
               character,
               style_format,
               local_format_id)]
```

       address            character style_format local_format_id
    1:     A32 badboldrightupindent          Bad              10

### Sales example spreadsheet

``` r
SalesCells <- xlsx_cells("data/annual_sales.xlsx")

setDT(SalesCells)
```

![](img/04-outline-example.png)

#### Describing cells’ outline level

- **row_outline_level**: The outline level of a cells’s row. In this
  example, we can see how the header and total rows are at first level,
  the subtotals are at second and the individual values are third level.

- **col_outline_level**: The outline level of a cells’s column. In the
  example, we don’t have group columns and all cells are at first level.

``` r
SalesCells[address %chin% paste0("A",1:18), 
           .(address,
             character,
             numeric,
             row_outline_level,
             col_outline_level)
  ][order(row_outline_level)]
```

        address   character numeric row_outline_level col_outline_level
     1:      A1     Quarter      NA                 1                 1
     2:     A18 Grand Total      NA                 1                 1
     3:      A5     1 Total      NA                 2                 1
     4:      A9     2 Total      NA                 2                 1
     5:     A13     3 Total      NA                 2                 1
     6:     A17     4 Total      NA                 2                 1
     7:      A2        <NA>       1                 3                 1
     8:      A3        <NA>       1                 3                 1
     9:      A4        <NA>       1                 3                 1
    10:      A6        <NA>       2                 3                 1
    11:      A7        <NA>       2                 3                 1
    12:      A8        <NA>       2                 3                 1
    13:     A10        <NA>       3                 3                 1
    14:     A11        <NA>       3                 3                 1
    15:     A12        <NA>       3                 3                 1
    16:     A14        <NA>       4                 3                 1
    17:     A15        <NA>       4                 3                 1
    18:     A16        <NA>       4                 3                 1

#### Describing cells’ dimensions

- **width**: The width of a cell’s column, in Excel’s units.
- **height**: The height of a cell’s row, in Excel’s units.

``` r
SalesCells[address %chin% paste0(LETTERS[1:3],"1"), 
           .(address,
             character,
             width,
             height)]
```

       address character    width height
    1:      A1   Quarter  8.38000   15.6
    2:      B1     Month 20.10938   15.6
    3:      C1     Sales 12.55469   15.6

## Tidying wild data with `unpivotr`

### behead: Sense-of-purpose example

1.  As we can see bellow the data starts at `[3,3]` with 7000, so all
    the rows and columns before that point are headers that needs to be
    defined

``` r
head(unpivotr::purpose$`up-left left-up`, 10L)
```

                      X2      X3     X4     X5    X6     X7
    1               <NA>    <NA> Female   <NA>  Male   <NA>
    2               <NA>    <NA>  0 - 6 7 - 10 0 - 6 7 - 10
    3  Bachelor's degree 15 - 24   7000  27000  <NA>  13000
    4               <NA> 25 - 44  12000 137000  9000  81000
    5               <NA> 45 - 64  10000  64000  7000  66000
    6               <NA>     65+   <NA>  18000  7000  17000
    7        Certificate 15 - 24  29000 161000 30000 190000
    8               <NA> 25 - 44  34000 179000 31000 219000
    9               <NA> 45 - 64  30000 210000 23000 199000
    10              <NA>     65+  12000  77000  8000 107000

2.  Once we undertand the current structure we can **tokenize** the data
    frame into one row per cell represented as new tibble of `row`,
    `col`, `data_type` and `chr`.

``` r
PurposeCells <- as_cells(unpivotr::purpose$`up-left left-up`)
head(PurposeCells)
```

    # A tibble: 6 × 4
        row   col data_type chr              
      <int> <int> <chr>     <chr>            
    1     1     1 chr       <NA>             
    2     2     1 chr       <NA>             
    3     3     1 chr       Bachelor's degree
    4     4     1 chr       <NA>             
    5     5     1 chr       <NA>             
    6     6     1 chr       <NA>             

3.  Let’s set the first row as the `sex` column by defining the
    direction to find the header from the data by going `up` and `left`
    if the cell in empty after going `up`.

``` r
PurposeCells |>
  behead(direction = "up-left",
         name = "sex") |>
  as.data.frame() |>
  head()
```

      row col data_type   chr    sex
    1   2   3       chr 0 - 6 Female
    2   3   3       chr  7000 Female
    3   4   3       chr 12000 Female
    4   5   3       chr 10000 Female
    5   6   3       chr  <NA> Female
    6   7   3       chr 29000 Female

4.  Confirm that the first row isn’t part of the problem to solve by
    using the `rectify` function.

``` r
PurposeCells |>
  behead(direction = "up-left",
         name = "sex") |>
  rectify() |>
  head(10L)
```

    # A tibble: 10 × 7
       `row/col` `1(A)`            `2(B)`  `3(C)` `4(D)` `5(E)` `6(F)`
           <int> <chr>             <chr>   <chr>  <chr>  <chr>  <chr> 
     1         2 <NA>              <NA>    0 - 6  7 - 10 0 - 6  7 - 10
     2         3 Bachelor's degree 15 - 24 7000   27000  <NA>   13000 
     3         4 <NA>              25 - 44 12000  137000 9000   81000 
     4         5 <NA>              45 - 64 10000  64000  7000   66000 
     5         6 <NA>              65+     <NA>   18000  7000   17000 
     6         7 Certificate       15 - 24 29000  161000 30000  190000
     7         8 <NA>              25 - 44 34000  179000 31000  219000
     8         9 <NA>              45 - 64 30000  210000 23000  199000
     9        10 <NA>              65+     12000  77000  8000   107000
    10        11 Diploma           15 - 24 <NA>   14000  9000   11000 

5.  Defining the `life-satisfication` column by going up from the data
    to report.

``` r
PurposeCells |>
  behead(direction = "up-left",
         name = "sex") |>
  behead("up", "life-satisfication") |>
  as.data.frame() |>
  head()
```

      row col data_type   chr    sex life-satisfication
    1   3   3       chr  7000 Female              0 - 6
    2   4   3       chr 12000 Female              0 - 6
    3   5   3       chr 10000 Female              0 - 6
    4   6   3       chr  <NA> Female              0 - 6
    5   7   3       chr 29000 Female              0 - 6
    6   8   3       chr 34000 Female              0 - 6

6.  Defining the `qualification` column by going to the left and up if
    the cell is empty.

``` r
PurposeCells |>
  behead(direction = "up-left",
         name = "sex") |>
  behead("up", "life-satisfication") |>
  behead("left-up", "qualification") |>
  as.data.frame() |>
  head()
```

      row col data_type    chr    sex life-satisfication     qualification
    1   3   3       chr   7000 Female              0 - 6 Bachelor's degree
    2   4   3       chr  12000 Female              0 - 6 Bachelor's degree
    3   5   3       chr  10000 Female              0 - 6 Bachelor's degree
    4   6   3       chr   <NA> Female              0 - 6 Bachelor's degree
    5   3   4       chr  27000 Female             7 - 10 Bachelor's degree
    6   4   4       chr 137000 Female             7 - 10 Bachelor's degree

7.  Defining the `age-band` column by going to the left in the remaining
    first row.

``` r
PurposeCells |>
  behead(direction = "up-left",
         name = "sex") |>
  behead("up", "life-satisfication") |>
  behead("left-up", "qualification") |>
  behead("left", "age-band") |>
  as.data.frame() |>
  head()
```

      row col data_type    chr    sex life-satisfication     qualification age-band
    1   3   3       chr   7000 Female              0 - 6 Bachelor's degree  15 - 24
    2   4   3       chr  12000 Female              0 - 6 Bachelor's degree  25 - 44
    3   5   3       chr  10000 Female              0 - 6 Bachelor's degree  45 - 64
    4   6   3       chr   <NA> Female              0 - 6 Bachelor's degree      65+
    5   3   4       chr  27000 Female             7 - 10 Bachelor's degree  15 - 24
    6   4   4       chr 137000 Female             7 - 10 Bachelor's degree  25 - 44

8.  Last but not least, we can rearrange the columns and transform the
    values from `character` to `integer`.

``` r
PurposeCells |>
  behead(direction = "up-left",
         name = "sex") |>
  behead("up", "life-satisfication") |>
  behead("left-up", "qualification") |>
  behead("left", "age-band") |>
  as.data.table() |>
  (\(DT) DT[, .(sex,
                `life-satisfication`,
                qualification,
                `age-band`,
                count = as.integer(chr))] )() |>
  head()
```

          sex life-satisfication     qualification age-band  count
    1: Female              0 - 6 Bachelor's degree  15 - 24   7000
    2: Female              0 - 6 Bachelor's degree  25 - 44  12000
    3: Female              0 - 6 Bachelor's degree  45 - 64  10000
    4: Female              0 - 6 Bachelor's degree      65+     NA
    5: Female             7 - 10 Bachelor's degree  15 - 24  27000
    6: Female             7 - 10 Bachelor's degree  25 - 44 137000

### behead_if: Parry Potter example

In the prior example each header was defined in single row or column,
but what can be do when **several headers share the same column**,
that’s when `behead_if` is really useful we can define conditions to see
only a particular subset of cells.

1.  Start importing the tokenized cells and cell’s formats.

``` r
hp_path <- system.file("extdata/harry-potter.xlsx", package = "unpivotr")

hp_cells <- xlsx_cells(hp_path, sheet = "pivoted")
setDT(hp_cells)

hp_formats <- xlsx_formats(hp_path)
```

![](img/09-hp-data.png) 2. Then define the `domitory` and `name` columns
using the `behead` function.

``` r
hp_cells[!is.na(content)] |>
  behead("up-left", "dormitory") |>
  behead("up", "name") |>
  rectify() |>
  as.data.table()
```

       row/col                      1(A) 2(B) 3(C) 4(D)         5(E)
    1:       3                    Castle   11   11    7            2
    2:       4                    Charms    2    6    0            0
    3:       5                   Potions    9    5    7            2
    4:       6                   Grounds    7    8   11            3
    5:       7                 Herbology    5    1    8 10 - really?
    6:       8 Care of Magical Creatures    2    7    3            3

3.  Then we can use the **bold** values of the left and up to the define
    the new column location.

``` r
hp_cells[!is.na(content)] |>
  behead("up-left", "dormitory") |>
  behead("up", "name") |>
  behead_if(hp_formats$local$font$bold[local_format_id],
            direction = "left-up",
            name = "location") |>
  rectify() |>
  as.data.table()
```

       row/col                      1(A) 2(B) 3(C) 4(D)         5(E)
    1:       3                      <NA>   11   11    7            2
    2:       4                    Charms    2    6    0            0
    3:       5                   Potions    9    5    7            2
    4:       6                      <NA>    7    8   11            3
    5:       7                 Herbology    5    1    8 10 - really?
    6:       8 Care of Magical Creatures    2    7    3            3

4.  After removing the **bold** headers we just need to select the left
    headers and create the new column subject leaving the related
    subtotal with that category empty.

``` r
hp_cells[!is.na(content)] |>
  behead("up-left", "dormitory") |>
  behead("up", "name") |>
  behead_if(hp_formats$local$font$bold[local_format_id],
            direction = "left-up",
            name = "location") |>
  behead("left",  "subject") |>
  as.data.table() |>
  subset(subset = is.na(subject),
         select = c("address",
                    "dormitory",
                    "name",
                    "location",
                    "subject",
                    "numeric"))
```

       address dormitory     name location subject numeric
    1:      B3     Witch Hermione   Castle    <NA>      11
    2:      C3     Witch    Ginny   Castle    <NA>      11
    3:      D3    Wizard    Harry   Castle    <NA>       7
    4:      E3    Wizard      Ron   Castle    <NA>       2
    5:      B6     Witch Hermione  Grounds    <NA>       7
    6:      C6     Witch    Ginny  Grounds    <NA>       8
    7:      D6    Wizard    Harry  Grounds    <NA>      11
    8:      E6    Wizard      Ron  Grounds    <NA>       3

5.  Finally, organize the data frame to report.

``` r
hp_cells[!is.na(content)] |>
  behead("up-left", "dormitory") |>
  behead("up", "name") |>
  behead_if(hp_formats$local$font$bold[local_format_id],
            direction = "left-up",
            name = "location") |>
  behead("left",  "subject") |>
  as.data.table() |>
  subset(subset = !is.na(subject)) |>
  (\(DT) DT[order(dormitory, name, location, subject),
            .(dormitory,
              name,
              location,
              subject,
              mark = numeric,
              other = character)] )()
```

        dormitory     name location                   subject mark        other
     1:     Witch    Ginny   Castle                    Charms    6         <NA>
     2:     Witch    Ginny   Castle                   Potions    5         <NA>
     3:     Witch    Ginny  Grounds Care of Magical Creatures    7         <NA>
     4:     Witch    Ginny  Grounds                 Herbology    1         <NA>
     5:     Witch Hermione   Castle                    Charms    2         <NA>
     6:     Witch Hermione   Castle                   Potions    9         <NA>
     7:     Witch Hermione  Grounds Care of Magical Creatures    2         <NA>
     8:     Witch Hermione  Grounds                 Herbology    5         <NA>
     9:    Wizard    Harry   Castle                    Charms    0         <NA>
    10:    Wizard    Harry   Castle                   Potions    7         <NA>
    11:    Wizard    Harry  Grounds Care of Magical Creatures    3         <NA>
    12:    Wizard    Harry  Grounds                 Herbology    8         <NA>
    13:    Wizard      Ron   Castle                    Charms    0         <NA>
    14:    Wizard      Ron   Castle                   Potions    2         <NA>
    15:    Wizard      Ron  Grounds Care of Magical Creatures    3         <NA>
    16:    Wizard      Ron  Grounds                 Herbology   NA 10 - really?
