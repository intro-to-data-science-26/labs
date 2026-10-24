library(tidyverse)
library(nycflights13)
library(DBI)
library(RSQLite)
library(dbplyr)


# Exercise 1
# Add airline names, keeping every flight
dplyr::glimpse(flights)
dplyr::glimpse(airlines)

flights |>
  dplyr::left_join(airlines, by = "carrier")


# Exercise 2
# Find airports with no matching destination in flights
airports |>
  dplyr::anti_join(flights, by = c("faa" = "dest")) |>
  dplyr::select(name, faa)


# Alternative: rename the airport code column before joining
airports |>
  dplyr::rename(dest = faa) |>
  dplyr::anti_join(flights, by = "dest") |>
  dplyr::select(name, dest)


# Exercise 3
# Connect to the database and create table references
con <- DBI::dbConnect(RSQLite::SQLite(), "07_databases/nycflights13.sqlite")
flights_db <- dplyr::tbl(con, "flights")
airports_db <- dplyr::tbl(con, "airports")

# Collect only the 10 destinations with the most flights
top_destinations <- flights_db |>
  dplyr::count(dest) |>
  dplyr::left_join(
    airports_db |> dplyr::select(faa, name),
    by = c("dest" = "faa")
  ) |>
  dplyr::arrange(desc(n)) |>
  head(10) |>
  dplyr::collect()

top_destinations

DBI::dbDisconnect(con)
