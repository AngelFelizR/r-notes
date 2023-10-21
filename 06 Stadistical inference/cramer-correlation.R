
# Internal Function

cramerV_2cols <- function(df,
                          V1,
                          V2,
                          ci,
                          ...){
  
  df <- data.table::copy(df)
  
  data.table::setnames(df, c(V1, V2), c("V1", "V2"))
  
  cramer_value <-
    df[, .N, c("V1", "V2")] |>
    data.table::dcast(V1 ~ V2, value.var = "N") |>
    (\(x) as.data.frame(x[, !c("V1")], row.names = x$V1) )() |>
    as.matrix() |>
    rcompanion::cramerV(ci = ci, ...)
  
  return(cramer_value)
  
}


# Function to export

## df: A data.table or data.frame with factor or character columns.
## unique: As `cramerV(x,y) == cramerV(y,x)`, it avoids calculating both results.
## ci: If TRUE, returns confidence intervals by bootstrap. May be slow.
## ...: Additional arguments passed to `cramerV`.

cramerV_df <- function(df,
                       unique = TRUE,
                       ci = FALSE,
                       ...){
  
  stopifnot("df must be data.frame" = is.data.frame(df))
  
  # Transforming the data.frame into a data.table
  if(!data.table::is.data.table(df)){
    df_class <- class(df)
    df <- data.table::as.data.table(df) 
  }
  
  # We just can apply the next process in data.frames with 
  # at least 2 categorical variables
  df <- 
    df[, .SD, 
       .SDcols = \(x) is.character(x) | is.factor(x)]
  stopifnot("df must have at least 2 categorical variables" = ncol(df) >= 2L)
  
  # Defining combinations to calculate
  comb <-
    if(unique){
      names(df) |>
        combn(2) |> 
        t() |>
        data.table::as.data.table()
    }else{
      data.table::CJ(V1 = names(df),
                     V2 = names(df)
      )[V1 != V2]
    }
  
  # Calculating cramer value
  all_cramers <-
    comb[,{
      if(ci){
        cramerV_2cols(df, V1, V2, ci, ...)
      }else{
        list(Cramer.V = rcompanion::cramerV(
          df[[V1]], 
          df[[V2]], 
          ci = ci, 
          ...
        ) )
      }
    },
    by = c("V1", "V2")]
  
  # Returning df to its original class
  if(!"data.table" %in% df_class){
    data.table::setattr(all_cramers, "class", df_class)
  }
  
  return(all_cramers)
}

# Example
set.seed(2024)
df <- data.frame(
  gender = sample(c("male", "female"), 100, replace = TRUE) |> factor(),
  race = sample(c("white", "blackr", "asian", "other"), 100, replace = TRUE),
  education = sample(c("high school", "college", "graduate"), 100, replace = TRUE),
  income = sample(c("low", "medium", "high"), 100, replace = TRUE)
)
set.seed(NULL)

cramerV_df(df)
cramerV_df(df, ci = TRUE)

