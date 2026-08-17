## import clean data
lotr_dat <- read_tsv("./session-03-automation/lotr_project/data/processed/lotr_clean.tsv") %>% 
  # reorder Species based on words spoken
  mutate(Species = reorder(Species, Words, sum))

## make a plot
p <- ggplot(lotr_dat, aes(x = Species, weight = Words)) + geom_bar()
ggsave("./session-03-automation/lotr_project/outputs/figures/barchart-words-by-species.png", p)

# Print message
print("Barchart saved.")