pacman::p_load(ggplot2, plotly, dplyr)
if (FALSE) {
  library(RSQLite)
  library(dbplyr)
}


# Setup -------------------------------------------------------------------


# Set up handles to database tables on app start
db <- dplyr::src_sqlite("movies.db")
omdb <- dplyr::tbl(db, "omdb")
tomatoes <- dplyr::tbl(db, "tomatoes")

# Join tables, filtering out those with <10 reviews, and select specified columns
all_movies <- dplyr::inner_join(omdb, tomatoes, by = "ID") %>%
  dplyr::filter(Reviews >= 10) %>%
  dplyr::select(ID, imdbID, Title, Year, Rating_m = Rating.x, Runtime, Released,
                Director, Writer, imdbRating, imdbVotes, Language, Country, Oscars,
                Rating = Rating.y, Meter, Reviews, Fresh, Rotten, userMeter, userRating, userReviews,
                BoxOffice, Production, Cast)

# Variables that can be put on the x and y axes
axis_vars <- c(
  "Tomato Meter" = "Meter",
  "Numeric Rating" = "Rating",
  "Number of reviews" = "Reviews",
  "Dollars at box office" = "BoxOffice",
  "Year" = "Year",
  "Length (minutes)" = "Runtime"
)

# Custom Function ---------------------------------------------------------

# For dropdown menu
actionLink <- function(inputId, ...) {
  tags$a(href='javascript:void',
         id=inputId,
         class='action-button',
         ...)
}


# Define UI ---------------------------------------------------------------

ui <- fluidPage(
  # Title panel 
  titlePanel("IDS — Movie explorer tool"),
  
  # Main body
  fluidRow(
    # left hand panel (width of 3)
    column(3,
           # Filtering panel
           wellPanel(
             h4("Filter"),
             sliderInput("reviews", "Minimum number of reviews on Rotten Tomatoes",
                         10, 300, 80, step = 10),
             sliderInput("year", "Year released", 1940, 2014, value = c(1970, 2014),
                         sep = ""),
             sliderInput("oscars", "Minimum number of Oscar wins (all categories)",
                         0, 4, 0, step = 1),
             sliderInput("boxoffice", "Dollars at Box Office (millions)",
                         0, 800, c(0, 800), step = 1),
             textInput("director", "Director name contains (e.g., Miyazaki)"),
             textInput("cast", "Cast names contains (e.g. Tom Hanks)")
           ),
           
           # Plot axis selector
           wellPanel(
             selectInput("xvar", "X-axis variable", axis_vars, selected = "Meter"),
             selectInput("yvar", "Y-axis variable", axis_vars, selected = "Reviews"),
             tags$small(paste0(
               "Note: The Tomato Meter is the proportion of positive reviews",
               " (as judged by the Rotten Tomatoes staff), and the Numeric rating is",
               " a normalized 1-10 score of those reviews which have star ratings",
               " (for example, 3 out of 4 stars)."
             ))
           )
    ),
    # right hand panel (width of 9)
    column(9,
           # specifying plotly::ggplotly() output
           plotlyOutput("plot1"),
           wellPanel(
             span("Number of movies selected:",
                  textOutput("n_movies")
             )
           )
    )
  )
)


# Define Server -----------------------------------------------------------

server <- function(input, output, session) {
  
  # Filter the movies, returning a data frame (inputs from sliders and text boxes)
  movies <- reactive({
    reviews <- input$reviews
    oscars <- input$oscars
    minyear <- input$year[1]
    maxyear <- input$year[2]
    minboxoffice <- input$boxoffice[1] * 1e6
    maxboxoffice <- input$boxoffice[2] * 1e6
    
    # Apply filters
    m <- all_movies %>%
      dplyr::filter(
        Reviews >= reviews,
        Oscars >= oscars,
        Year >= minyear,
        Year <= maxyear,
        BoxOffice >= minboxoffice,
        BoxOffice <= maxboxoffice
      ) %>%
      dplyr::arrange(Oscars)
    
    # Optional: filter by director
    if (!is.null(input$director) && input$director != "") {
      # As our data is an SQL database, we need to use SQL LIKE syntax to match patterns in strings
      # This works similarly to Regular Expressions, but with % as a wildcard for any number of characters
      # Hint: for excercise 3 you can just copy this block of code and change it to match the inputted Genre.
      director <- paste0("%", input$director, "%")
      m <- m %>% filter(Director %like% director)
    }
    # Optional: filter by cast member
    if (!is.null(input$cast) && input$cast != "") {
      cast <- paste0("%", input$cast, "%")
      m <- m %>% filter(Cast %like% cast)
    }
    
    # return m
    m <- as.data.frame(m)
    
    # Add column which says whether the movie won any Oscars
    # Be a little careful in case we have a zero-row data frame
    m$has_oscar <- character(nrow(m))
    m$has_oscar[m$Oscars == 0] <- "No"
    m$has_oscar[m$Oscars >= 1] <- "Yes"
    m
  })
  
  # Function for generating tooltip text
  movie_tooltip <- function(x) {
    if (is.null(x)) return(NULL)
    if (is.null(x$ID)) return(NULL)
    
    # Pick out the movie with this ID
    all_movies <- shiny::isolate(movies()) # avoid having a reactive movies df
    movie <- all_movies[all_movies$ID == x$ID, ]
    
    paste0("<b>", movie$Title, "</b><br>",
           movie$Year, "<br>",
           "$", format(movie$BoxOffice, big.mark = ",", scientific = FALSE)
    )
  }
  
  # A reactive expression with the ggplot2 plot
  vis <- reactive({
    xvar_name <- names(axis_vars)[axis_vars == input$xvar]
    yvar_name <- names(axis_vars)[axis_vars == input$yvar]
    
    df <- movies()  # store once so we don't call movies() repeatedly
    
    # Build ggplot
    p <- ggplot(
      df,
      aes_string(
        x = input$xvar,
        y = input$yvar,
        fill = "has_oscar",
        colour = "has_oscar",
        text = "paste0(
        '<b>', Title, '</b><br>',
        'Year: ', Year, '<br>',
        'Box Office: $', round(BoxOffice / 1000000, digits = 1), 'm'
      )"
      )
    ) +
      geom_point(shape = 21, alpha = 0.7) +
      scale_fill_manual(values = c("Yes" = "orange", "No" = "gray"),name = "Won an Oscar") +
      scale_color_manual(values = c("Yes" = "orange", "No" = "gray"),guide = "none") +
      labs(
        x = xvar_name,
        y = yvar_name
      ) +
      theme_minimal()
    
    # Convert to plotly
    ggplotly(p, tooltip = "text", height = 400)
  })
  
  
  # Render plotly output
  output$plot1 <- renderPlotly({
    vis()
  })
  
  output$n_movies <- renderText({ nrow(movies()) })
}


# Compiling the App -------------------------------------------------------

shinyApp(ui = ui, server = server)
