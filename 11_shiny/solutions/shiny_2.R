library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(DT)
library(palmerpenguins)


# Setup -------------------------------------------------------------------

# Drop rows with missing values
penguins_clean <- na.omit(penguins)

measurements <- c(
  "Bill length (mm)" = "bill_length_mm",
  "Bill depth (mm)" = "bill_depth_mm",
  "Flipper length (mm)" = "flipper_length_mm",
  "Body mass (g)" = "body_mass_g"
)


# Define UI ---------------------------------------------------------------
ui <- page_sidebar(
  title = "Palmer penguins",
  sidebar = sidebar(
    selectInput("measurement", "Measurement", choices = measurements),
    # Exercise 2: choose the plot type
    radioButtons(
      "plot_type",
      "Plot type",
      choices = c("Density", "Histogram"),
      selected = "Density"
    )
  ),
  # Exercise 1: one tab for the plot and one for the table
  navset_card_underline(
    nav_panel("Distribution", plotOutput("distribution")),
    nav_panel("Data", DTOutput("penguin_table"))
  )
)


# Define server -----------------------------------------------------------
server <- function(input, output) {
  # Plot
  output$distribution <- renderPlot({
    # .data[[ ]] picks the column whose name is stored in input$measurement
    p <- ggplot(penguins_clean, aes(x = .data[[input$measurement]], fill = species))

    # Exercise 2: draw a density or a histogram
    if (input$plot_type == "Density") {
      p <- p + geom_density(alpha = 0.5, linewidth = 0.3)
    } else {
      p <- p + geom_histogram(bins = 15, alpha = 0.6, position = "identity")
    }

    p +
      labs(
        x = names(measurements)[measurements == input$measurement],
        y = if (input$plot_type == "Density") "Density" else "Penguins",
        fill = "Species"
      ) +
      theme_minimal(base_size = 14) +
      theme(legend.position = "bottom")
  })

  # Table
  output$penguin_table <- renderDT({
    datatable(penguins_clean, rownames = FALSE)
  })
}


# Run the app -------------------------------------------------------------

shinyApp(ui = ui, server = server)
