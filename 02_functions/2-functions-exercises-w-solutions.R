# Coding Solutions - Session 2

# Exercise 1 
# Base R solution
get_mode <- function(v) {
  v <- na.omit(v)
  uniq_v <- unique(v)
  
  return(uniq_v[which.max(tabulate(match(v, uniq_v)))])
  
}

# Way 1: tidyverse solution
library(tidyverse)
get_mode <- function(v) {
  as.data.frame(v) |> 
    filter(!is.na(v)) |> 
    count(v, sort = TRUE) |> 
    slice(1) |> 
    pull(v)
}

# Way 3:
get_mode <- function(x){
  freq_table <- table(x)
  my_mode <- as.numeric(names(which.max(freq_table)))
  return(my_mode)
}

#Ex 2
get_mode(penguins$flipper_length_mm) 


#Ex 3
purrr::map_dbl(df, mean, na.rm = TRUE)

#Ex 4
mean_sd <- function(x){
  if(!(is.numeric(x))) {
    # stop("x is not a numeric value")
    return(NULL)
  } else{ 
    list("mean" = mean(x, na.rm = TRUE),
         "sd" = sd(x, na.rm = TRUE))
  }  
}


#Ex 5
#Way 1:list
map(penguins %>% select_if(is.numeric), mean_sd)


#Way 2: dataframe
map_df(penguins |> select(where(is.numeric)), mean_sd) |> 
  cbind(
    'col' = penguins |> 
      select(where(is.numeric)) |> 
      colnames()
  )
