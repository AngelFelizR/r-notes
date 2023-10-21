# load packages
library(data.table)

get_cramer <- function(df,
                       V1,
                       V2,
                       ...){
  
  df <- copy(df)
  
  setnames(df, c(V1, V2), c("V1", "V2"))
  
  df[, .N, c("V1", "V2")] |>
    tidytext::cast_sparse("V1", "V2", "N") |>
    as.matrix() |>
    rcompanion::cramerV(...)
}

get_chr_cramer <- function(df, ...){
  
  df <- df[, .SD, .SDcols = is.character]
  
  Comb <-
    seq_len(ncol(df)-1) |>
    lapply(\(x) names(df)[-(1:x)]) |>
    mapply(FUN = \(V1,V2) CJ(V1,V2),
           V1 = names(df) |> head(-1L),
           V2 = _,
           SIMPLIFY = FALSE) |>
    rbindlist()
  
  Comb[, .(cramer = get_cramer(df, V1, V2, ...)),
       by = c("V1", "V2")]
}

# create a sample data frame
df <- data.table(
  gender = sample(c("male", "female"), 100, replace = TRUE),
  race = sample(c("white", "black", "asian", "other"), 100, replace = TRUE),
  education = sample(c("high school", "college", "graduate"), 100, replace = TRUE),
  income = sample(c("low", "medium", "high"), 100, replace = TRUE)
)

get_chr_cramer(df)



