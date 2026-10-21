library(tidyverse)
library(nycflights13)

# Exercise 1
# Inspect the tables and identify matching columns
dplyr::glimpse(flights)
dplyr::glimpse(airlines)

# a) Add airline names, keeping every flight
flights |>
  dplyr::left_join(airlines, by = "carrier")

# b) Find the airline with the most flights operated by planes missing from the registry
dplyr::glimpse(planes)

flights |>
  dplyr::anti_join(planes, by = "tailnum") |>
  dplyr::count(carrier, sort = TRUE) |>
  dplyr::left_join(airlines, by = "carrier") |>
  dplyr::slice_max(n, n = 5)


# Exercise 2
# a) Inspect the airports dataset
head(nycflights13::airports)
# or
dplyr::glimpse(nycflights13::airports)

# b) Add the airports table with the appropriate index
dplyr::copy_to(
  dest = con, 
  df = nycflights13::airports, 
  name = "airports",
  temporary = FALSE, 
  indexes = "faa"
)


# Exercise 3
# Create reference to airlines table
airlines_db <- dplyr::tbl(con, "airlines")

# a) Join, filter, and limit (all happens on database)
jan1_flights <- flights_db |>
  dplyr::filter(month == 1, day == 1) |>
  dplyr::left_join(airlines_db, by = "carrier") |>
  dplyr::select(carrier, name, flight) 

# b) Now collect into local dataframe
jan1_flights_local <- jan1_flights |> dplyr::collect()
jan1_flights_local
