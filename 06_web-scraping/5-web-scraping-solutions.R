# solutions for the exercises
library(tidyverse)
library(rvest)


# Exercise 1
# Precise XPath from Chrome
parsed_url |> 
  rvest::html_element(xpath = '//*[@id="mw-content-text"]/div[1]/p[8]') |> 
  rvest::html_text2()


# More flexible, getting the second paragraph of the header Roman Cologne
parsed_url |> 
  rvest::html_element(xpath = '//h3[@id="Roman_Cologne"]/following::p[2]') |> 
  rvest::html_text2()



# Exercise 2
## Exercise a: What does it take to be within the top-100 most streamed songs on Spotify? 
## (i.e., how many streams?)

# min to be in the table
spotify_table |>
  select(streams_billions) |>
  min()

## Exercise b: Which artists have the highest number of most streamed songs?
## (Note that the artist_s string might contain multiple unique artists)
## This one also includes bonus exercise c: Which artists has the most cumulative streams?
spotify_table |> 
  group_by(artist_s) |> 
  summarise(songs_n = n(), 
            total_streams_billions = sum(streams_billions)) |> 
  arrange(desc(total_streams_billions))


# Looking a bit more closely, there are collaborations in the data
spotify_table$artist_s # separators between artists: and, &, with, featuring


# Definition 1: each artist as an independent artists, duplicating streams
artists <- spotify_table |>
  separate_rows(artist_s, sep = "\\s*(and|featuring|&|with)\\s*") |> #this will separate each artist into independent ones
  mutate(artist_s = str_trim(artist_s)) |> #trim unnecessary whitespaces
  group_by(artist_s) |>
  summarise(songs = n(),
            total_streams_billions = sum(streams_billions)) 

# desired output for b
artists |> arrange(desc(songs))
# for c
artists |> arrange(desc(total_streams_billions))

# Definition 2: considering only the "main" artist
mains <- spotify_table|>
  mutate(artist = if_else(str_detect(artist_s,"(and|featuring|&|with)"), #detecting if there is any of these words in the string
                          str_extract(artist_s, "^(.*?)(?=\\s+(and|with|featuring|&)\\s)"), #extracting the first artist
                          artist_s),
  artist = str_trim(artist)
  ) |>
  group_by(artist) |>
  summarise(songs = n(),
            total_streams_billions = sum(streams_billions))

## breaking down the regular expression pattern: ^(.*?)(?=\\s+(and|with|featuring|&)\\s)
# ^(.*?) starts with anything and this is a lazy character, so break when the following structure happens
# (?=pattern) R will check if this pattern occurs but will not output it in the match
# \\s+(and|with|featuring|&)\\s either of these occur between spaces


#for b
mains |> arrange(desc(songs))
# for c
mains |> arrange(desc(total_streams_billions))
