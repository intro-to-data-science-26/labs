# Solutions
pacman::p_load(
  tidyverse,
  foreign,
  palmerpenguins,
  haven,
  gapminder,
  gridExtra,
  viridis
)

df <- gapminder 



# Exercise 1 
advanced_scatter <- ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g, color = species)) +
  geom_point() +
  labs(title = "Advanced plot",
       x = "Flipper Length",
       y = " Body Mass (g)",
       color = "Species") +
  theme_bw() +
  theme(legend.position = "bottom")


# (!)  Histogram, gapminder
  # What conclusions might you draw from the histogram above about the distribution of life expectancy worldwide?
    # The distribution is not normal (i.e. not a bell curve). It is bimodal with a skew to the left. 
    # There is a cluster of country-year observations that has a lower life expectancy (approximately 45-60 years), 
    # and a cluster of countries with much higher life expectancies (approx 70 years).*


# Exercise 2
# Histogram
ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(bins = 15, fill = "#FF6666") + 
  theme_minimal()

# Boxplot and violin
# Box plot of body mass grouped by species
ggplot(penguins, aes(x = species, y = body_mass_g)) +
  geom_boxplot(fill = "#FF6666") +
  theme_minimal()

# Violin plot of body mass grouped by species
ggplot(penguins, aes(x = species, y = body_mass_g)) +
  geom_violin(fill = "#FF6666") + 
  theme_minimal()


# (!) Scatterplot 
  # Can you explain the differences between the plot applying the natural log to the variable within the `aes()` 
  # function versus using `scale_x_continuous()`?
    # *Transforming the variable using the natural logarithm within `aes()` causes the x-axis to be displayed in log 
    # values. Using `scale_x_continuous()`, the data is transformed in the same way, however, the x-axis is displayed 
    # in the original, non-logged version.*


# Exercise 3 
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g, color = species)) +
  geom_point(alpha = 0.6, size = 1.2) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(x = "Flipper length (mm)", y = "Body mass (g)", color = "Species") +
  theme_minimal()


# Exercise 4
ggplot(
  subset(df, country %in% c("Brazil", "China", "India", "South Africa")),
  aes(x = year,
      y = gdpPercap)) +
  geom_line(alpha = 0.5) +
  geom_point(alpha = 0.8,
             size = 0.4) +
  theme_light() +
  labs(title = "GDP per capita in BRICS countries",
       x = "Year",
       y = "GDP per capita") +
  facet_wrap(~country, nrow = 1) +
  scale_x_continuous(breaks = seq(1950,2000, 25))
