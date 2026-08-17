#Coding Solutions - Session 1

# Base R section
# Ex 1 - Look at the output from the function above. How many observations (rows) and variables (columns) does the penguins dataset have? What different data types do you see?


# Ex 2 - Access the species information (column 1) for the 10th penguin in the dataset using indexing.
penguins[10, 1]
#or
penguins[10, "species"]

# Ex 3 - Access rows 15 through 20 and columns 1 through 3 of the penguins dataset.
penguins[15:20, 1:3]

# Ex 4 - Create a table showing the distribution of penguin sex by species. What do you notice about the missing values?
table(penguins$species, penguins$sex, useNA = "always")

# Ex 5
female_biscoe <- penguins[penguins$sex == "female" & penguins$island == "Biscoe", ]
nrow(female_biscoe)

# Tidyverse Section

#Ex 1 - The following code chunk would select the variables we need. Can you adapt it, so that we keep the body_mass_g and sex variables as well?
dplyr::select(penguins, species, island, year, body_mass_g, sex)

#Ex 2 - We can leverage the pipe operator to sequence our code in a logical manner. Can you adapt the following code chunk with the pipe and conditional logical operators we discussed?
penguins |>
  dplyr::filter(year == 2009 & species == "Chinstrap") |>
  dplyr::select(species, sex, year)

#Ex 3 - Can you get the weight of the lightest penguin of each species? You can use `min()`. What happens when in addition to species you also group by year `group_by(species, year)`?
penguins |>
  dplyr::group_by(species, year) |>
  dplyr::summarize(lightest_penguin = min(body_mass_g, na.rm = T))

#Ex 4 - Can you create a data frame arranged by body_mass_g of the penguins observed in the "Dream" island?

penguins |>
  dplyr::filter(island == "Dream") |>
  dplyr::arrange(body_mass_g)

