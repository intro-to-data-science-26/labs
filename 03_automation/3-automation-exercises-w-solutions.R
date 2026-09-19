# Debugging ####
library(gaminder) # package name

gapminder_selected <- gapminder |> # df assignment missing
  select(continent, pop)


gapminder_summary <- gapminder_selected |>
  group_by(continent) # pipe missing 
  summarise(
    mean_pop = mean(pop, na.rm = TRUE) # TRUE or T
  )

gapminder_summary


# Automation exercises: ####
# #**Exercise 1**

## import clean data
lotr_dat <- read_tsv("./03_automation/lotr_project/data/processed/lotr_clean.tsv") %>% 
  # reorder Species based on words spoken
  mutate(Species = reorder(Species, Words, sum))

# create summary table by species and movie
summary_table <- lotr_dat %>%
  group_by(Species, Film) %>%
  summarize(
    Characters = n(),
    Words = sum(Words),
    .groups = "drop"
  )

# save summary table
write_tsv(summary_table, "./03_automation/lotr_project/outputs/tables/lotr_summary_table.tsv")


# #**Exercise 2**
## clean out any previous work
outputs <- c("./03_automation/lotr_project/data/raw/lotr_raw.tsv",
             "./03_automation/lotr_project/data/processed/lotr_clean.tsv",
             "./03_automation/lotr_project/outputs/tables/lotr_summary_table.tsv",
             list.files(path =  "./03_automation/lotr_project/outputs/figures/",pattern = "*.png$", full.names = TRUE))
file.remove(outputs)

#OR

# clean out any previous work
files_to_remove <- c(
  "./03_automation/lotr_project/data/raw/lotr_raw.tsv",
  "./03_automation/lotr_project/data/processed/lotr_clean.tsv",
  list.files(path =  "./03_automation/lotr_project/outputs/tables/",pattern = "*.tsv$", full.names = TRUE),
  list.files(path =  "./03_automation/lotr_project/outputs/figures/",pattern = "*.png$", full.names = TRUE))


