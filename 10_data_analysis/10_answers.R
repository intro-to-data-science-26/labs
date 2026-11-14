# 10_answers.R
# Run from the labs project root

# -- EXERCISE 1 --
# 1A
library(tidyverse)

emissions <- read_csv(
  "10_data_analysis/data/owid_emissions.csv",
  show_col_types = FALSE
)

# 1B
# co2_per_capita is production-based emissions, in tonnes per person
emissions <- emissions |>
  select(country, iso_code, year, co2_per_capita)

glimpse(emissions)
head(emissions)
emissions |>
  distinct(country, iso_code) |>
  print(n = Inf)

# ANSWER: iso_code (or country) and year make each row unique
# ANSWER: regional and world totals, such as "Africa" and "World", have no iso_code

# 1C
# Country codes have three capital letters
emissions <- emissions |>
  filter(str_detect(iso_code, "^[A-Z]{3}$"))
# Alternatively: As the totals have no iso_code, you can also filter out NA values:
emissions |>
  filter(!is.na(iso_code)) # with the current version of dplyr: filter_out(is.na(iso_code))
nrow(emissions)
# ANSWER: 42,480 rows

# -- EXERCISE 2 --
# 2A
library(readxl)

gdp_pop <- read_excel("10_data_analysis/data/owid_gdp_population.xlsx")
gdp_pop <- gdp_pop |>
  select(code, year, gdp, population)

glimpse(gdp_pop)
head(gdp_pop)

# 2B
nrow(emissions)
# ANSWER: 42,480 rows before the join

# ANSWER: the code column is called code in the Excel file, not iso_code
# ANSWER: year is character in the Excel file, numeric in the CSV
gdp_pop <- gdp_pop |>
  rename(iso_code = code) |>
  mutate(year = as.numeric(year))

co2_gdp <- emissions |>
  left_join(gdp_pop, by = c("iso_code", "year"))

nrow(co2_gdp)
# ANSWER: 42,480 rows after the join; the row count did not change
# ANSWER: it shouldn't; a left join keeps every row of emissions, and each
# iso_code and year pair appears only once in gdp_pop

# -- EXERCISE 3 --
# 3A
co2_gdp |>
  summarize(
    co2_na = sum(is.na(co2_per_capita)),
    gdp_na = sum(is.na(gdp)),
    population_na = sum(is.na(population))
  )

# ANSWER: GDP (27,250 rows)

# 3B
countries <- co2_gdp |>
  drop_na(co2_per_capita, gdp, population)

latest_year <- max(countries$year)

country_data <- countries |>
  filter(year == latest_year)

nrow(country_data)
# ANSWER: 2022, with 164 countries; GDP data stops in 2022

# 3C
missing_countries <- co2_gdp |>
  filter(year == latest_year) |>
  anti_join(country_data, by = "iso_code")

missing_countries |>
  select(country, co2_per_capita, gdp, population) |>
  print(n = Inf)

# ANSWER: 54 countries, all missing GDP
# ANSWER: mostly small island states, microstates (Monaco, San Marino) and
# territories (Aruba, Greenland), plus conflict-affected countries (Somalia,
# Sudan, South Sudan, Eritrea)
# ANSWER: the remaining countries are mostly larger and more stable. Results may
# not apply to small islands, territories or countries in conflict

# -- EXERCISE 4 --
# 4A
country_data <- country_data |>
  mutate(gdp_per_capita = gdp / population)

# 4B
# ANSWER: gdp_per_capita is in 2011 international dollars per person
# (GDP in 2011 international dollars divided by population in people)
# ANSWER: co2_per_capita is in tonnes per person
country_data |>
  select(gdp_per_capita, co2_per_capita) |>
  summary()
# or
country_data |>
  summarize(
    gdp_mean = mean(gdp_per_capita),
    gdp_median = median(gdp_per_capita),
    gdp_min = min(gdp_per_capita),
    gdp_max = max(gdp_per_capita),
    co2_mean = mean(co2_per_capita),
    co2_median = median(co2_per_capita),
    co2_min = min(co2_per_capita),
    co2_max = max(co2_per_capita)
  )

# ANSWER: GDP per capita: mean about 19,149; median about 12,606
# ANSWER: CO2 per capita: mean about 4.53; median about 2.84

country_data |>
  arrange(desc(gdp_per_capita)) |>
  select(country, gdp_per_capita) |>
  head(5)
country_data |>
  arrange(desc(co2_per_capita)) |>
  select(country, co2_per_capita) |>
  head(5)

# ANSWER: highest GDP per capita: Qatar, Norway, Singapore, United Arab
# Emirates, Switzerland
# ANSWER: highest CO2 per capita: Qatar, Kuwait, Trinidad and Tobago,
# Bahrain, Saudi Arabia
# ANSWER: a few countries have very high values. These increase the mean but
# barely change the median, so the mean is much higher than the median

# 4C
plot_colors <- RColorBrewer::brewer.pal(5, "RdBu")

country_data |>
  pivot_longer(
    cols = c(gdp_per_capita, co2_per_capita),
    names_to = "variable",
    values_to = "value"
  ) |>
  ggplot(aes(value)) +
  geom_density(fill = plot_colors[1], alpha = 0.7) +
  facet_wrap(~variable, scales = "free") +
  labs(x = NULL, y = "Density") +
  theme_minimal()

# ANSWER: scales = "free" gives each panel its own axes. GDP per capita goes up
# to about 132,000 dollars and CO2 per capita only to about 38 tonnes. On a
# shared axis, the CO2 values are all close to zero and you can't see their shape
# ANSWER: both distributions are right-skewed: most countries have low values
# and a few have very high ones

# -- EXERCISE 5 --
# 5A
ggplot(country_data, aes(gdp_per_capita, co2_per_capita)) +
  geom_point(color = plot_colors[1], alpha = 0.7) +
  labs(
    x = "GDP per person (2011 international dollars)",
    y = "Production-based CO2 (tonnes per person)"
  ) +
  theme_minimal()

# ANSWER: positive; richer countries tend to emit more per person, but most
# countries are bunched at low values

# 5B
country_data |>
  summarize(min_gdp = min(gdp_per_capita), min_co2 = min(co2_per_capita))

# ANSWER: yes, with logs; both variables are right-skewed
# ANSWER: no zero or negative values; no rows to remove

ggplot(country_data, aes(gdp_per_capita, co2_per_capita)) +
  geom_point(color = plot_colors[1], alpha = 0.7) +
  geom_smooth(method = "loess", color = "gray30") +
  scale_x_log10() +
  scale_y_log10() +
  labs(
    x = "GDP per person (2011 international dollars; log scale)",
    y = "Production-based CO2 (tonnes per person; log scale)"
  ) +
  theme_minimal()

# ANSWER: the points spread out, and the relationship looks close to a
# straight line

# -- EXERCISE 6 --
regions <- read_csv(
  "10_data_analysis/data/owid_regions.csv",
  show_col_types = FALSE
)
glimpse(regions)

regions <- regions |>
  select(iso_code = Code, region = `World region according to OWID`)

country_data <- country_data |>
  left_join(regions, by = "iso_code")

ggplot(country_data, aes(gdp_per_capita, co2_per_capita, color = region)) +
  geom_point(alpha = 0.7) +
  scale_color_brewer(palette = "Set1") +
  scale_x_log10() +
  scale_y_log10() +
  labs(
    x = "GDP per person (2011 international dollars; log scale)",
    y = "Production-based CO2 (tonnes per person; log scale)",
    color = "Region"
  ) +
  theme_minimal()

# ANSWER: many African countries are in the lower left (low income, low emissions)
# ANSWER: European countries generally have higher incomes and emissions per person
# ANSWER: regions overlap; region alone does not determine emissions

# -- EXERCISE 7 --
# 7A
model_data <- country_data |>
  mutate(
    log_gdp = log(gdp_per_capita),
    log_co2 = log(co2_per_capita)
  ) |>
  select(country, log_gdp, log_co2)

set.seed(21)

# Get indices representing 80% of the data
train_rows <- sample(
  seq_len(nrow(model_data)),
  size = floor(0.80 * nrow(model_data))
)

train_data <- model_data |>
  dplyr::slice(train_rows)

test_data <- model_data |>
  dplyr::slice(-train_rows)

# 7B
model_recipe <- recipes::recipe(log_co2 ~ log_gdp, data = train_data)

model_spec <- parsnip::linear_reg() |>
  parsnip::set_engine("lm")

model_workflow <- workflows::workflow() |>
  workflows::add_recipe(model_recipe) |>
  workflows::add_model(model_spec)

model_fit <- model_workflow |>
  parsnip::fit(data = train_data)

broom::tidy(model_fit)

# ANSWER: slope about 1.04; 1% higher GDP per person goes with about 1% higher
# emissions per person

# 7C
test_predictions <- predict(
  model_fit,
  new_data = test_data
) |>
  dplyr::bind_cols(test_data) |>
  mutate(error = log_co2 - .pred)

test_predictions |>
  yardstick::metrics(
    truth = log_co2,
    estimate = .pred
  )

ggplot(test_predictions, aes(log_co2, .pred)) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "gray50") +
  geom_point(color = plot_colors[1], alpha = 0.7) +
  coord_equal() +
  labs(x = "Observed log CO2 per person", y = "Predicted log CO2 per person") +
  theme_minimal()

test_predictions |>
  arrange(desc(abs(error))) |>
  select(country, log_co2, .pred, error) |>
  head(5)

# ANSWER: test RMSE about 0.571 (natural log units)
# ANSWER: largest errors: Venezuela, Uganda, Kazakhstan, Iran, Ukraine
# ANSWER: oil and gas producers (Venezuela, Kazakhstan, Iran) and Ukraine's
# heavy industry emit more than income predicts; Uganda emits less

# 7D
test_predictions |>
  mutate(observed = exp(log_co2), predicted = exp(.pred)) |>
  summarize(
    rmse_tonnes = sqrt(mean((observed - predicted)^2)),
    mean_emissions = mean(observed)
  )

# ANSWER: RMSE about 2.50 tonnes per person; mean emissions about 4.55
# ANSWER: large; the typical error is more than half of mean emissions
