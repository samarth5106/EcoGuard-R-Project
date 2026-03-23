library(shiny)
library(leaflet)
library(bslib)
library(tidyverse)
library(ggplot2)
library(shinyWidgets)
library(httr)

ui <- page_navbar(
  title = span("EcoGuard: India Intelligence Map", style = "font-weight: bold;"),
  theme = bs_theme(version = 5, bootswatch = "darkly"),
  
  header = tags$head(
    tags$style(HTML("
      /* DARK MODE NAVBAR FIX */
      .navbar { background-color: #0d1b2a !important; border-bottom: 2px solid #00b4d8; }
      .navbar .navbar-brand, .navbar .nav-link { color: #ffffff !important; }
      
      /* LIGHT MODE */
      body { transition: 0.3s; }
      
      .card { border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.2); margin-top: 10px; }
    "))
  ),
  
  sidebar = sidebar(
    title = "Controls",
    
    materialSwitch("theme_toggle", "Dark Mode", value = TRUE),
    hr(),
    
    h6("Analysis Type:"),
    radioGroupButtons(
      inputId = "analysis_mode",
      label = NULL,
      choices = c("Pollution (AQI)" = "aqi", "Crime Density" = "crime"),
      justified = TRUE
    ),
    
    hr(),
    uiOutput("click_info")
  ),
  
  nav_panel("Map",
            leafletOutput("map", height = "calc(100vh - 80px)")
  )
)

server <- function(input, output, session) {
  
  # Theme switch
  observe({
    new_theme <- if (input$theme_toggle) {
      bs_theme(bootswatch = "darkly")
    } else {
      bs_theme(bootswatch = "flatly")
    }
    session$setCurrentTheme(new_theme)
  })
  
  # Base map
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.DarkMatter) %>%
      setView(lng = 79.0882, lat = 21.1458, zoom = 5)
  })
  
  # Tile switching
  observe({
    proxy <- leafletProxy("map")
    proxy %>% clearTiles()
    
    if (input$theme_toggle) {
      proxy %>% addProviderTiles(providers$CartoDB.DarkMatter)
    } else {
      proxy %>% addProviderTiles(providers$CartoDB.Positron)
    }
  })
  
  # Store last clicked point (IMPORTANT FIX)
  clicked <- reactiveVal(NULL)
  
  observeEvent(input$map_click, {
    clicked(input$map_click)
  })
  
  # Score logic
  generate_score <- function(lat, lng, mode) {
    base <- if(mode == "aqi") 200 else 50
    variation <- abs(sin(lat) * cos(lng)) * 100
    
    if(mode == "aqi") {
      round(base + variation)
    } else {
      round(base + variation/2)
    }
  }
  
  # MAIN reactive logic (FIXED GRAPH ISSUE)
  observe({
    req(clicked())
    
    click <- clicked()
    
    # API call
    res <- GET(
      url = "https://nominatim.openstreetmap.org/reverse",
      query = list(format = "json", lat = click$lat, lon = click$lng),
      add_headers(`User-Agent` = "EcoGuard-App")
    )
    
    place_name <- if(status_code(res) == 200) {
      content(res)$display_name %>%
        str_split(",") %>%
        unlist() %>%
        .[1]
    } else {
      "Unknown Location"
    }
    
    val <- generate_score(click$lat, click$lng, input$analysis_mode)
    
    # MORE DETAILS FOR CRIME (your requirement)
    crime_types <- c("Theft", "Assault", "Cybercrime", "Fraud")
    crime_data <- sample(10:50, 4)
    
    risk_level <- case_when(
      val < 100 ~ "Low",
      val < 200 ~ "Moderate",
      val < 300 ~ "High",
      TRUE ~ "Severe"
    )
    
    color <- case_when(
      risk_level == "Low" ~ "green",
      risk_level == "Moderate" ~ "yellow",
      risk_level == "High" ~ "orange",
      TRUE ~ "red"
    )
    
    # Map update
    leafletProxy("map") %>%
      clearMarkers() %>%
      clearPopups() %>%
      addCircleMarkers(
        lng = click$lng,
        lat = click$lat,
        radius = 10,
        color = color,
        fillOpacity = 0.8
      ) %>%
      addPopups(
        click$lng, click$lat,
        paste0(
          "<b>", place_name, "</b><br>",
          "Score: ", val, "<br>",
          "Risk: ", risk_level
        )
      )
    
    # Sidebar output (DYNAMIC NOW)
    output$click_info <- renderUI({
      card(
        card_header(paste("Location:", place_name)),
        
        p(paste("Score:", val)),
        p(paste("Risk Level:", risk_level)),
        
        if(input$analysis_mode == "crime") {
          tagList(
            h6("Crime Breakdown:"),
            renderPlot({
              df <- data.frame(Type = crime_types, Value = crime_data)
              
              ggplot(df, aes(Type, Value, fill = Type)) +
                geom_col() +
                theme_minimal() +
                labs(title = "Crime Distribution")
            }, height = 220)
          )
        } else {
          renderPlot({
            ggplot(data.frame(x="AQI", y=val), aes(x, y)) +
              geom_col(fill="red", width=0.5) +
              geom_text(aes(label = val), vjust = -0.5) +
              theme_minimal() +
              ylim(0, 400) +
              labs(title = "Air Quality Index")
          }, height = 220)
        }
      )
    })
    
  })
}

shinyApp(ui, server)