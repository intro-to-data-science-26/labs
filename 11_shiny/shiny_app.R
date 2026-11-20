library(shiny)
library(dplyr)
library(ggplot2)
library(gapminder)
library(DT)


# Setup -------------------------------------------------------------------

# Change in life expectancy since 1952 for each country
gap <- gapminder |>
  group_by(country) |>
  mutate(life_change = lifeExp - first(lifeExp)) |>
  ungroup()

continents <- sort(unique(as.character(gap$continent)))
years <- sort(unique(gap$year))

# Use the same axes for every year so the plots can be compared
gdp_range <- range(gap$gdpPercap)
life_range <- range(gap$lifeExp)


# Define UI ---------------------------------------------------------------
ui <- fluidPage(
  titlePanel("Gapminder explorer"),
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "continent",
        "Continent",
        choices = continents,
        selected = "Africa"
      ),
      selectInput("year", "Year", choices = years, selected = max(years))
    ),
    mainPanel(
      plotOutput("scatter"),
      DTOutput("country_table")
    )
  )
)


# Define server -----------------------------------------------------------
server <- function(input, output) {
  # Data for the chosen continent and year
  selected <- reactive({
    gap |>
      filter(continent == input$continent, year == input$year)
  })
  
  # Plot
  output$scatter <- renderPlot({
    ggplot(selected(), aes(x = gdpPercap, y = lifeExp, size = pop)) +
      geom_point(alpha = 0.6, color = "#2f1a61") +
      scale_size_continuous(guide = "none") +
      scale_x_continuous(limits = gdp_range) +
      scale_y_continuous(limits = life_range) +
      labs(
        title = "Life expectancy and GDP per capita",
        x = "GDP per capita (US$)",
        y = "Life expectancy (years)"
      ) +
      theme_minimal(base_size = 14)
  })

  # Table output
  output$country_table <- renderDT({
    table_data <- selected() |>
      arrange(desc(lifeExp)) |>
      select(
        Country = country,
        `Life expectancy (years)` = lifeExp,
        `Change since 1952 (years)` = life_change,
        `GDP per capita (US$)` = gdpPercap,
        Population = pop
      )

    datatable(table_data, rownames = FALSE, options = list(pageLength = 10)) |>
      formatRound(
        c("Life expectancy (years)", "Change since 1952 (years)"),
        digits = 1
      ) |>
      formatCurrency("GDP per capita (US$)", currency = "", digits = 0) |>
      formatRound("Population", digits = 0)
  })
}


# Run the app -------------------------------------------------------------

shinyApp(ui = ui, server = server)
