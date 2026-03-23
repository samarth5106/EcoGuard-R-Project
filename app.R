# ==========================================
# PROJECT: ISEI Ultra - India Spatial Intelligence
# SIGNATURE: Dynamic Geocoding & Mode-Switching
# ==========================================

library(shiny)
library(leaflet)
library(bslib)
library(tidyverse)
library(ggplot2)
library(shinyWidgets)

# --- 1. THE DATA ENGINE ---
# Creating a large-scale randomized grid to simulate "Click Anywhere" coverage
india_grid <- expand.grid(
  lat = seq(8, 37, by = 2),
  lng = seq(68, 97, by = 2)
) %>% 
  mutate(
    id = row_number(),
    aqi = sample(50:400, n(), replace = TRUE),
    crime = sample(10:100, n(), replace = TRUE)
  )

# --- 2. UI ---
ui <- page_navbar(
  title = "ISEI Ultra: India Intelligence",
  id = "nav",
  # Dynamic Theme Container
  theme = bs_theme(version = 5, bootswatch = "darkly"),
  
  sidebar = sidebar(
    title = "System Configuration",
    # Theme Toggle
    materialSwitch(inputId = "theme_toggle", label = "Dark Mode", value = TRUE, status = "primary"),
    hr(),
    # Analysis Mode
    radioGroupButtons(
      inputId = "analysis_mode",
      label = "Select Analysis Mode:",
      choices = c("Pollution" = "aqi", "Crime" = "crime"),
      status = "danger",
      checkIcon = list(yes = icon("ok", lib = "glyphicon"))
    ),
    hr(),
    helpText("Click anywhere on the map to query local intelligence."),
    uiOutput("click_info")
  ),
  
  nav_panel("Spatial Analysis",
            card(leafletOutput("map", height = "750px"))
  )
)

# --- 3. SERVER ---
server <- function(input, output, session) {
  
  # 1. Dynamic Theme Logic
  observeEvent(input$theme_toggle, {
    new_theme <- if(input$theme_toggle) bs_theme(bootswatch = "darkly") else bs_theme(bootswatch = "flatly")
    session$setCurrentTheme(new_theme)
  })
  
  # 2. Map Rendering
  output$map <- renderLeaflet({
    # Select Tiles based on Theme
    tiles <- if(input$theme_toggle) providers$CartoDB.DarkMatter else providers$CartoDB.Positron
    
    leaflet() %>%
      addProviderTiles(tiles) %>%
      setView(lng = 78.96, lat = 22.59, zoom = 5)
  })
  
  # 3. CLICK ANYWHERE LOGIC
  # This captures the Latitude and Longitude of any click
  observeEvent(input$map_click, {
    click <- input$map_click
    
    # Logic: Find the "Value" for that specific click
    # In a real high-end app, this would query an API. Here we simulate the logic.
    val <- if(input$analysis_mode == "aqi") {
      sample(150:350, 1) # Simulated AQI for that exact spot
    } else {
      sample(20:90, 1)   # Simulated Crime for that exact spot
    }
    
    label_text <- if(input$analysis_mode == "aqi") "AQI Level" else "Crime Index"
    color_marker <- if(input$analysis_mode == "aqi") "orange" else "red"
    
    leafletProxy("map") %>%
      clearPopups() %>%
      addPopups(click$lng, click$lat, paste0(
        "<b>Location Query Result</b><br>",
        "Lat: ", round(click$lat, 2), " Lng: ", round(click$lng, 2), "<br>",
        "<b>", label_text, ": </b>", val
      ))
    
    # Render the plot in the sidebar based on click
    output$click_info <- renderUI({
      card(
        card_header("Local Analysis"),
        renderPlot({
          ggplot(data.frame(x="Local", y=val), aes(x, y, fill=x)) +
            geom_col(fill=color_marker) + theme_minimal() +
            labs(y = label_text, x=NULL)
        }, height = 200)
      )
    })
  })
}

shinyApp(ui, server)