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
  fillable = FALSE, # let the page scroll so the table fits below the plot
  sidebar = sidebar(
    selectInput("measurement", "Measurement", choices = measurements)
  ),
  card(card_header("Distribution"), plotOutput("distribution")),
  card(card_header("Data"), DTOutput("penguin_table"))
)


# Define server -----------------------------------------------------------
server <- function(input, output) {
  # Plot
  output$distribution <- renderPlot({
    # .data[[ ]] picks the column whose name is stored in input$measurement
    ggplot(penguins_clean, aes(x = .data[[input$measurement]], fill = species)) +
      geom_density(alpha = 0.5, linewidth = 0.3) +
      labs(
        x = names(measurements)[measurements == input$measurement],
        y = "Density",
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
