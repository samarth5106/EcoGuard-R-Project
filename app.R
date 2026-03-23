# ==========================================
# PROJECT: ISEI - Advanced India Intelligence Hub
# FEATURES: Live Data Simulation, Time-Reactive Risk, Multi-City Analytics
# ==========================================

library(shiny)
library(leaflet)
library(bslib)
library(tidyverse)
library(ggplot2)
library(leafpop)

# --- 1. DATA ENGINE (Expanded City List) ---
base_data <- data.frame(
  city = c("Delhi", "Mumbai", "Bengaluru", "Pune", "Hyderabad", "Chennai", 
           "Kolkata", "Ahmedabad", "Surat", "Jaipur", "Lucknow", "Kanpur", 
           "Nagpur", "Indore", "Thane", "Bhopal", "Visakhapatnam"),
  lat = c(28.61, 19.07, 12.97, 18.52, 17.38, 13.08, 22.57, 23.02, 21.17, 26.91, 26.84, 26.44, 21.14, 22.71, 19.21, 23.25, 17.68),
  lng = c(77.20, 72.87, 77.59, 73.85, 78.48, 80.27, 88.36, 72.57, 72.83, 75.78, 80.94, 80.33, 79.08, 75.85, 72.97, 77.41, 83.21),
  base_aqi = c(310, 140, 85, 90, 115, 95, 200, 180, 150, 170, 240, 250, 130, 140, 145, 135, 110),
  base_crime = c(88, 52, 35, 28, 42, 38, 65, 45, 40, 50, 75, 80, 40, 42, 48, 44, 30)
)

# --- 2. UI ---
ui <- page_navbar(
  title = "ISEI: Advanced India Intelligence Hub",
  theme = bs_theme(version = 5, bootswatch = "darkly"),
  
  nav_panel("Live Risk Map",
            layout_sidebar(
              sidebar = sidebar(
                h4("System Controls"),
                selectInput("time", "Time of Day (Live Simulation):", 
                            choices = c("Morning", "Afternoon", "Evening", "Night")),
                hr(),
                card(
                  card_header("Risk Logic"),
                  helpText("Night: High Crime/Med AQI"),
                  helpText("Afternoon: Med Crime/High AQI (Smog)"),
                  uiOutput("avg_stats")
                )
              ),
              leafletOutput("map", height = "750px")
            )
  )
)

# --- 3. SERVER ---
server <- function(input, output, session) {
  
  # REACTIVE ENGINE: This changes the data based on TIME
  processed_data <- reactive({
    # Multipliers based on Time of Day
    mult <- switch(input$time,
                   "Morning"   = list(aqi = 0.8, crime = 0.6),
                   "Afternoon" = list(aqi = 1.2, crime = 0.7),
                   "Evening"   = list(aqi = 1.4, crime = 1.1),
                   "Night"     = list(aqi = 1.0, crime = 1.5))
    
    base_data %>%
      mutate(
        current_aqi = base_aqi * mult$aqi,
        current_crime = base_crime * mult$crime,
        livability_score = round(100 - ((current_aqi/5) + (current_crime/2)), 1)
      ) %>%
      mutate(livability_score = pmax(0, pmin(100, livability_score))) # Keep between 0-100
  })
  
  output$map <- renderLeaflet({
    df <- processed_data()
    
    # ggplot generator for popups
    plot_list <- lapply(1:nrow(df), function(i) {
      p_df <- data.frame(Metric = c("Pollution", "Crime"), 
                         Value = c(df$current_aqi[i], df$current_crime[i]))
      ggplot(p_df, aes(x=Metric, y=Value, fill=Metric)) +
        geom_bar(stat="identity") + theme_minimal() +
        scale_fill_manual(values=c("#e74c3c", "#f39c12")) +
        labs(title = df$city[i])
    })
    
    pal <- colorNumeric(palette = "RdYlGn", domain = c(0, 100))
    
    leaflet(df) %>%
      addProviderTiles(providers$CartoDB.DarkMatter) %>%
      setView(lng = 78.96, lat = 22.59, zoom = 5) %>%
      addCircleMarkers(
        radius = ~livability_score/4 + 5,
        color = ~pal(livability_score),
        fillOpacity = 0.8,
        layerId = ~city,
        group = "cities"
      ) %>%
      leafpop::addPopupGraphs(plot_list, group = "cities", width = 250, height = 150)
  })
  
  output$avg_stats <- renderUI({
    df <- processed_data()
    avg <- round(mean(df$livability_score), 1)
    tagList(h3(avg, style = "color: #00bc8c;"), "National Index")
  })
}

shinyApp(ui, server)