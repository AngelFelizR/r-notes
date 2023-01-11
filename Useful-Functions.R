
# 1. Simple and general ----

## 1.1. Importing functions ---- 

read_excel_DT <- function(... , rename_vec, key_vec){
  
  DT <- as.data.table(read_excel(...)) 
  
  if(!missing(rename_vec)){
    setnames(DT, rename_vec, names(rename_vec))
  }
  
  if(!missing(key_vec)){
    setkeyv(DT, key_vec)
  }
  
  return(DT)
  
}


extract_excel_col_types <- function(DF,
                                    select,
                                    collapse.vector = TRUE,
                                    logical.type = "date"){
  
  
  Df_classes <-
    vapply(DF, \(x) class(x) |> paste0(collapse = "_"), FUN.VALUE = "") |>
    (\(x) fcase(x == "character", "text",
                x %chin% c("POSIXct_POSIXt","Date"), "date",
                x == "numeric", "numeric",
                x == "logical", logical.type))()
  
  names(Df_classes) <- names(DF)
  
  if(!missing(select)){
    Df_classes[!names(Df_classes) %chin% select] <- "skip"
  }
  
  if(!collapse.vector){
    return(Df_classes)
  }
  
  paste0("'",names(Df_classes),"' = '",type = Df_classes,"'") |>
    paste0(collapse = ",\n") |>
    cat()
  
}


extract_M_col_types <- function(DF,
                                select,
                                collapse.vector = TRUE,
                                logical.type = "date"){
  
  
  Df_classes <-
    vapply(DF, \(x) class(x) |> paste0(collapse = "_"), FUN.VALUE = "") |>
    (\(x) fcase(x == "character", "type text",
                x %chin% c("POSIXct_POSIXt","Date"), "type date",
                x == "numeric", "type number",
                x == "logical", "type logical",
                x == "integer", "Int64.Type"))()
  
  names(Df_classes) <- names(DF)
  
  if(!missing(select)){
    Df_classes[!names(Df_classes) %chin% select] <- "skip"
  }
  
  if(!collapse.vector){
    return(Df_classes)
  }
  
  paste0('{"',names(Df_classes),'", ',type = Df_classes,'}') |>
    paste0(collapse = ", ")
  
}




## 1.2. Working with lists ---- 


split_by_var <- function(DATA, 
                         split_var,
                         lookup_v,
                         name_suffix){
  
  if(missing(lookup_v)){
    DATA[, split_value := get(split_var)]
  }else{
    DATA[, split_value := lookup_v[get(split_var)]]
  }
  
  setkey(DATA, split_value)
  
  split_names <- DATA[, unique(split_value)] |> sort()
  
  split_list <-
    lapply(split_names,
           function(x) DATA[.(x), !c("split_value"), nomatch = NULL])
  
  
  names(split_list) <- 
    if(missing(name_suffix)){
      split_names
    }else{
      paste0(split_names,name_suffix)
    }
  
  return(split_list)
  
}


add_source <- function(list.DF, source.name = "source"){
  
  lapply(seq_along(list.DF),
         function(tb_i){
           setDT(list.DF[[tb_i]])[, (source.name) := names(list.DF)[tb_i] ] })
  
}


## 1.3. Cleaning ----

clean_amount <- function(value) {
  
  # For some weird reason gsub didn't want to remove white spaces so 
  # we start using stringr::str_remove_all
  
  str_remove_all(value, pattern = "'|,|\\s") |>
    (\(x) fifelse(x == "-",NA_character_,x))() |>
    as.double()
  
}

replace_na_inf <- function(x, replacement = 0){
  
  fifelse(is.na(x) | is.infinite(x), replacement, x) 
  
} 


na_if_nan <- function(x){
  x[is.nan(x)] <- NA
  x
}

## 1.4.  Programming with data.table ----

# Use it insite of lapply
write_name_inside_function <- function(as_name_var, fun_name){
  call(fun_name, as_name_var)
} 

# Use it insite of Reduce
add_each_name <- function(x, y){
  call("+", x, y)
} 

# Output Use Example
# copy(.SD)[, `:=`(`Total` = (total_sum) > 0),
#           env = list(total_sum = sum_j_expr)]  



substitute_list_to_j_expr <- function(substitute_list) {
  
  # Input Example
  
  # list("Total1" = 
  #        substitute2(expr = sum(values, na.rm = TRUE),
  #                    env = list(values = "DTVarName1")),
  #      "Total2" =
  #        substitute2(expr = sum(values, na.rm = TRUE),
  #                    env = list(values = "DTVarName2"))) 
  
  col_names <- names(substitute_list)
  
  total_cols <-
    setNames(nm = col_names) |>
    as.list() |>
    list(expr_name = _) |>
    substitute2(expr = expr_name)
  
  call_col_names <- col_names[sapply(substitute_list, is.call)]
  
  for(pipe_col_i  in call_col_names){
    total_cols[[pipe_col_i]] <- substitute_list[[pipe_col_i]]
  }
  
  return(total_cols)
  
  
  # Output Use Example
  
  #   DT[, totals,
  #      by = .(DTVarName3),
  #      env = list(totals = j_expr)]
  
}


## 1.5. Validation functions ----


custom_validation <- function(DF,
                              ...,
                              external.var.list = vector(mode = "list"),
                              broken.rules = vector(mode = "character")){
  
  rules <- 
    validator(...) 
  
  summary_result <- 
    confront(DF,
             x = rules,
             ref = external.var.list) |>
    summary(confront_result)
  
  
  if(length(broken.rules) == 0){
    broken.rules <- 
      subset(summary_result, items == nrow(DF) & fails > 0)[["name"]]
  }
  
  
  if(length(broken.rules) > 0){
    
    names(broken.rules) <- broken.rules
    
    attr(summary_result,"broken_rules") <-
      lapply(broken.rules, \(rule) violating(DF, rules[rule])) |>
      add_source(source.name = "Broken Rule") |>
      rbindlist()
    
  }
  
  return(summary_result)
  
}


warning_if_problem <- function(DF, message_text){
  
  if(sum(DF$fails) != 0){
    print(message_text)
    print(DF[DF$fails != 0, ])
    print("")
    warning(message_text)
  }
  
  invisible(DF)
  
}


stop_if_problem <- function(DF, message_text){
  
  if(sum(DF$fails) != 0){
    print(message_text)
    print(DF[DF$fails != 0, ])
    print("")
    stop(message_text)
  }
  
}
