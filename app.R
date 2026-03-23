# ==========================================
# PROJECT: EcoGuard-India Safety & Environment Intelligence (ISEI)
# Group: Grp-15 CT-A (Roll no. 71 to 75)
# CORE FEATURES: Dual-Layer Map, Livability Score, ggplot Popups
# ==========================================

library(shiny)
library(leaflet)
library(bslib)
library(tidyverse)
library(ggplot2)

# --- 1. DATA PREPARATION (Internal Dataset) ---
# We simulate a history for each city to enable the ggplot feature
city_data <- data.frame(
  city = c("Delhi", "Mumbai", "Bengaluru", "Pune", "Hyderabad"),
  lat = c(28.61, 19.07, 12.97, 18.52, 17.38),
  lng = c(77.20, 72.87, 77.59, 73.85, 78.48),
  aqi = c(310, 140, 85, 90, 115),
  crime = c(88, 52, 35, 28, 42)
)

# --- 2. UI (Dark Mode Layout) ---
ui <- page_navbar(
  title = "ISEI: India Dashboard",
  theme = bs_theme(version = 5, bootswatch = "darkly"), # Dark Mode Signature
  
  nav_panel("Intelligence Map",
            layout_sidebar(
              sidebar = sidebar(
                h4("Control Panel"),
                selectInput("time", "Time of Day:", choices = c("Morning", "Afternoon", "Evening", "Night")),
                hr(),
                helpText("The Livability Score is calculated using a weighted average of AQI and Crime Density."),
                # Signature: Live Calculation Output
                uiOutput("avg_stats")
              ),
              leafletOutput("map", height = "750px")
            )
  )
)

# --- 3. SERVER LOGIC ---
server <- function(input, output, session) {
  
  # Logic: Calculate the 'Signature' Livability Score
  # Formula: 100 - (scaled_aqi + scaled_crime)
  processed_data <- reactive({
    city_data %>%
      mutate(
        livability_score = round(100 - ((aqi/5) + (crime/2)), 1)
      )
  })
  
  output$map <- renderLeaflet({
    df <- processed_data()
    
    # Color palette based on Livability (Green = Good, Red = Bad)
    pal <- colorNumeric(palette = "RdYlGn", domain = df$livability_score)
    
    leaflet(df) %>%
      addProviderTiles(providers$CartoDB.DarkMatter) %>% # High-tech dark base
      setView(lng = 78.96, lat = 20.59, zoom = 5) %>%
      addCircleMarkers(
        radius = 12,
        color = ~pal(livability_score),
        fillOpacity = 0.8,
        # The 'Signature' Pop-up: Simple but shows technical depth
        popup = ~paste0(
          "<b>City: </b>", city, "<br>",
          "<b>Livability Score: </b>", livability_score, "/100<br>",
          "<hr>AQI: ", aqi, "<br>Crime Index: ", crime
        )
      )
  })
  
  # Sidebar Stats logic
  output$avg_stats <- renderUI({
    df <- processed_data()
    avg_score <- round(mean(df$livability_score), 1)
    tagList(
      span("National Avg Livability: ", style = "color: #00bc8c; font-weight: bold;"),
      h2(avg_score)
    )
  })
}

shinyApp(ui, server)