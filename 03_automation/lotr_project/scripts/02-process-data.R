## import raw data
lotr_dat <- read_tsv("./session-03-automation/lotr_project/data/raw/lotr_raw.tsv")

## reorder Film factor levels based on story
old_levels <- levels(as.factor(lotr_dat$Film))
j_order <- sapply(c("Fellowship", "Towers", "Return"),
                  function(x) grep(x, old_levels))
new_levels <- old_levels[j_order]

lotr_dat <- lotr_dat %>%
  rename(Species = Race) %>%
  # apply new factor levels to Film
  mutate(Film = factor(as.character(Film), new_levels),
         # revalue Species
         Species = recode(Species, `Ainur` = "Wizard", `Men` = "Man")) %>%
  # drop least frequent Species
  filter(!(Species %in% c("Gollum", "Ent", "Dead", "Nazgul"))) %>%
  # reorder Species based on words spoken
  mutate(Species = reorder(Species, Words, sum)) %>%
  # arrange the data on Species, Film, Words
  arrange(Species, Film, Words) %>%
  # drop levels
  droplevels
  
# write data to file
write_tsv(lotr_dat, file = "./session-03-automation/lotr_project/data/processed/lotr_clean.tsv")

# Print message
print("Data processed and saved.")