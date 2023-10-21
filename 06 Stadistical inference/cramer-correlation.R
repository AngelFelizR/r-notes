
# Dependencies ----

# install.packages("data.table")
# install.packages("rcompanion")

sessionInfo()

# R version 4.2.3 (2023-03-15 ucrt)
# Platform: x86_64-w64-mingw32/x64 (64-bit)
# Running under: Windows 10 x64 (build 22621)
# 
# Matrix products: default
# 
# locale:
# [1] LC_COLLATE=English_United States.utf8 
# [2] LC_CTYPE=English_United States.utf8   
# [3] LC_MONETARY=English_United States.utf8
# [4] LC_NUMERIC=C                          
# [5] LC_TIME=English_United States.utf8    
# 
# attached base packages:
# [1] stats     graphics  grDevices
# [4] utils     datasets  methods  
# [7] base     
# 
# loaded via a namespace (and not attached):
# [1] Rcpp_1.0.11       
# [2] plyr_1.8.7        
# [3] cellranger_1.1.0  
# [4] compiler_4.2.3    
# [5] class_7.3-21      
# [6] tools_4.2.3       
# [7] boot_1.3-28.1     
# [8] rootSolve_1.8.2.4 
# [9] lattice_0.20-45   
# [10] Matrix_1.5-3      
# [11] rstudioapi_0.15.0 
# [12] parallel_4.2.3    
# [13] mvtnorm_1.2-3     
# [14] expm_0.999-7      
# [15] coin_1.4-3        
# [16] libcoin_1.0-10    
# [17] e1071_1.7-13      
# [18] withr_2.5.1       
# [19] httr_1.4.7        
# [20] DescTools_0.99.50 
# [21] nortest_1.0-4     
# [22] gld_2.6.6         
# [23] stats4_4.2.3      
# [24] lmtest_0.9-40     
# [25] grid_4.2.3        
# [26] data.table_1.14.8 
# [27] R6_2.5.1          
# [28] readxl_1.4.3      
# [29] survival_3.5-3    
# [30] lmom_3.0          
# [31] multcomp_1.4-25   
# [32] TH.data_1.1-2     
# [33] codetools_0.2-19  
# [34] matrixStats_1.0.0 
# [35] modeltools_0.2-23 
# [36] MASS_7.3-58.2     
# [37] splines_4.2.3     
# [38] Exact_3.2         
# [39] multcompView_0.1-9
# [40] sandwich_3.0-2    
# [41] proxy_0.4-27      
# [42] rcompanion_2.4.34 
# [43] zoo_1.8-12   

# Internal Function ----

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


# Function to export ----

# Arguments

## df: A data.table or data.frame with factor or character columns.
## unique: As `cramerV(x,y) == cramerV(y,x)`, it avoids calculating both results.
## ci: If TRUE, returns confidence intervals by bootstrap. May be slow.
## ...: Additional arguments passed to `cramerV`.

# Value

## A data.frame with the `Cramer.V` for each combination of categorical variable
## present in the original `df`

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

