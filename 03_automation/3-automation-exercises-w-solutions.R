# Iteration recap exercises: ####

# Exercise 1: Nest the Data
penguins_nested <- penguins %>%
  group_by(species) %>%
  nest()

# Exercise 2: Create Summary Function
summarize_bills <- function(df) {
  df %>%
    summarise(
      count = n(),
      mean_bill_length = mean(bill_length_mm, na.rm = TRUE),
      max_bill_length = max(bill_length_mm, na.rm = TRUE)
    )
}

# Test
summarize_bills(penguins_nested$data[[1]])

# Exercise 3: Apply with map()
penguins_nested <- penguins_nested %>%
  mutate(bill_stats = map(data, summarize_bills))

# Exercise 4: Unnest Results
penguins_summary <- penguins_nested %>%
  select(species, bill_stats) %>%
  unnest(bill_stats)

# Exercise 5: Complete Pipeline
final_summary <- penguins %>%
  group_by(species) %>%
  nest() %>%
  mutate(bill_stats = map(data, summarize_bills)) %>%
  select(species, bill_stats) %>%
  unnest(bill_stats)

final_summary


# Automation exercises: ####
# #**Exercise 1**

## import clean data
lotr_dat <- read_tsv("./session-03-automation/lotr_project/data/processed/lotr_clean.tsv") %>% 
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
write_tsv(summary_table, "./session-03-automation/lotr_project/outputs/tables/lotr_summary_table.tsv")

# #**Exercise 2**
## clean out any previous work
outputs <- c("./session-03-automation/lotr_project/data/raw/lotr_raw.tsv",
             "./session-03-automation/lotr_project/data/processed/lotr_clean.tsv",
             "./session-03-automation/lotr_project/outputs/tables/lotr_summary_table.tsv",
             list.files(path =  "./session-03-automation/lotr_project/outputs/figures/",pattern = "*.png$", full.names = TRUE))
file.remove(outputs)

#OR

# clean out any previous work
files_to_remove <- c(
  "./session-03-automation/lotr_project/data/raw/lotr_raw.tsv",
  "./session-03-automation/lotr_project/data/processed/lotr_clean.tsv",
  list.files(path =  "./session-03-automation/lotr_project/outputs/tables/",pattern = "*.tsv$", full.names = TRUE),
  list.files(path =  "./session-03-automation/lotr_project/outputs/figures/",pattern = "*.png$", full.names = TRUE))
)


# Take home debugging exercise ####
# load packages
library(tidyverse)
library(legislatoR) 

# get political data on German legislators
political_df <- left_join(x = get_political(legislature = 'deu') |> filter(session == 18), 
                          y = get_core(legislature = "deu"), by = "pageid")

# wiki traffic data
traffic_df <- get_traffic(legislature = "deu") |> 
  filter(date >= "2013-10-22" & date <= "2017-10-24") |> 
  group_by(pageid) |> 
  summarize(traffic_mean = mean(traffic, na.rm = TRUE),
            traffic_max = max(traffic, na.rm = TRUE))

# sessions served
sessions_served_df <- get_political(legislature = "deu") |> 
  group_by(pageid) |> 
  dplyr::summarize(sessions_served = n())

# merge
legislator_df <- 
  left_join(political_df, sessions_served_df, by = "pageid") |> 
  left_join(traffic_df, by = "pageid") 

# compute age
get_age <- function(birth, date_at) {
  date_at_fmt <- date_at
  birth_fmt <- birth
  diff <- difftime(lubridate::ymd(date_at_fmt), lubridate::ymd(birth_fmt))
  diff_years <- lubridate::time_length(diff, "years")
  diff_years
}
legislator_df$age_in_years <- round(get_age(legislator_df$birth, "2017-10-24"), 0)

# plot top 10 pageviews
legislator_df <- arrange(legislator_df, desc(traffic_mean))
legislator_df$rank <- 1:nrow(legislator_df)
legislator_df_table <- legislator_df |> dplyr::select(rank, name, traffic_mean, traffic_max)
colnames(legislator_df_table) <- c("Rank", "Representative", "Mean", "Maximum")
legislator_df_table <- head(legislator_df_table, 10)

ggplot(legislator_df_table, aes(y = Mean, x = -Rank)) + 
  xlab("Rank") + ylab("Avg. daily page views") + 
  labs(title = "Top 10 representatives by average daily page views") + 
  geom_col(stats = "identity") + 
  scale_x_continuous(breaks = -nrow(legislator_df_table):-1, labels = rev(1:nrow(legislator_df_table))) +
  geom_text(aes(y = 10, label = Representative), hjust = 0, color = "white", size = 2) + 
  coord_flip() + 
  theme_minimal()

# run model of page views as a function of sessions served, party, sex, and age in years
legislator_df$traffic_log <- log(legislator_df$traffic_mean)

covars <- c("sessions_served", "party", "sex", "age_in_years")
fmla <- paste("traffic_log", paste(covars, collapse = " + "), sep = " ~ ") 
summary(log_traffic_model <- lm(fmla, legislator_df))

sjPlot::tab_model(log_traffic_model)
