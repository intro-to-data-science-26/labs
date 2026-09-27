# Excercise 1

# 1.
formula_string1 <- paste("life_expectancy", "~ gdp + population + alcohol")
formula1 <- as.formula(formula_string1)
reg1 <- lm(formula1, data = life_expec_dat)
summary(reg1)

# 2.
formula_string2 <- paste("life_expectancy", "~ gdp * population + alcohol")
formula2 <- as.formula(formula_string2)
reg2 <- lm(formula2, data = life_expec_dat)
summary(reg2)

# 3.
formula_string3 <- paste("life_expectancy", "~ gdp + I(gdp^2) + log(population)")
# Same as formula_string3 <- "life_expectancy ~ gdp + I(gdp^2) + I(log(population))". As log() is a function, it doesn't necessarily need I().
formula3 <- as.formula(formula_string3)
reg3 <- lm(formula3, data = life_expec_dat)
summary(reg3)

# Excercise 2

summary(multiv_model_out[[10]])
summary(multiv_model_out[[25]])
summary(multiv_model_out[[31]])

# Excercise 3
mod_table <- modelsummary::modelsummary(multiv_model_out[29:31], 
                                        output = "kableExtra",
                                        fmt = fmt_significant(2),  # 2 significant digits instead of fixed decimal places
                                        estimate  = "{estimate}",
                                        statistic = "conf.int",
                                        coef_omit = "Intercept",
                                        coef_rename=c("gdp"="Gdp", 
                                                      "bmi"="Avg. BMI", 
                                                      "alcohol" = "Alcohol Consum.",
                                                      "hiv_aids"= "HIV cases", 
                                                      "percentage_expenditure" = "Health Expenditure (% of GDP)",
                                                      "life_expectancy" = "Life Expectancy"),
                                        gof_omit = 'DF|Deviance|Log.Lik|AIC|BIC',
                                        title = 'An Improved Regression Table',
                                        notes = "Data sourced from the WHO via (https://www.kaggle.com/kumarajarshi/life-expectancy-who)",
                                        escape = FALSE) |> 
  kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"), full_width = F, fixed_thead = T) |> 
  row_spec(3, color = 'red') |>
  row_spec(5, background = 'lightblue') # These shoudl be changed based on your own preferences.


mod_table