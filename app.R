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
library(leafpop)

# --- 1. DATA PREPARATION (Internal Dataset) ---
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
  theme = bs_theme(version = 5, bootswatch = "darkly"), 
  
  nav_panel("Intelligence Map",
            layout_sidebar(
              sidebar = sidebar(
                h4("Control Panel"),
                selectInput("time", "Time of Day:", choices = c("Morning", "Afternoon", "Evening", "Night")),
                hr(),
                helpText("The Livability Score is calculated using a weighted average of AQI and Crime Density."),
                uiOutput("avg_stats")
              ),
              leafletOutput("map", height = "750px")
            )
  )
)

# --- 3. SERVER LOGIC ---
server <- function(input, output, session) {
  
  # Logic: Calculate Livability Score
  processed_data <- reactive({
    city_data %>%
      mutate(livability_score = round(100 - ((aqi/5) + (crime/2)), 1))
  })
  
  # Function to create a small plot for each city
  create_plot <- function(city_name, aqi_val, crime_val) {
    p <- ggplot(data.frame(Category=c("AQI", "Crime"), Value=c(aqi_val, crime_val)), 
                aes(x=Category, y=Value, fill=Category)) +
      geom_bar(stat="identity", show.legend = FALSE) +
      theme_minimal() + 
      labs(title = paste(city_name, "Metrics")) +
      scale_fill_manual(values=c("#e74c3c", "#3498db"))
    return(p)
  }
  
  output$map <- renderLeaflet({
    df <- processed_data()
    
    # Create a list of plots for each marker
    plot_list <- lapply(1:nrow(df), function(i) {
      create_plot(df$city[i], df$aqi[i], df$crime[i])
    })
    
    pal <- colorNumeric(palette = "RdYlGn", domain = df$livability_score)
    
    leaflet(df) %>%
      addProviderTiles(providers$CartoDB.DarkMatter) %>%
      setView(lng = 78.96, lat = 20.59, zoom = 5) %>%
      addCircleMarkers(
        radius = 15,
        color = ~pal(livability_score),
        fillOpacity = 0.8,
        group = "cities"
      ) %>%
      leafpop::addPopupGraphs(plot_list, group = "cities", width = 300, height = 200)
  })
  
  # Sidebar Stats logic - Corrected position inside server
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