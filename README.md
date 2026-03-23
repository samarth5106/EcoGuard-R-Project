# 🌍 EcoGuard: India Intelligence Map 


## 📌 Project Overview
EcoGuard is an interactive spatial intelligence web application built using **R Shiny**. It provides a high-level dashboard for geographical risk analysis across India. Unlike static maps, EcoGuard allows users to click any coordinate on the map to trigger a real-time "Intelligence Probe," analyzing **Pollution (AQI)** and **Crime Density** for that specific location.

The system fuses interactive mapping, live API geocoding, and reactive data visualization into a single, seamless user experience.

---

## 🎯 Objectives
- **Interactive Spatial Querying:** Enable users to probe any point in India via map clicks.
- **Live Geocoding:** Fetch real-time location names (City/Town/District) using external APIs.
- **Risk Visualization:** Dynamically generate AQI and Crime insights based on geographical coordinates.
- **Dual-State UI:** Provide a professional interface with instant Light/Dark mode switching.
- **Actionable Analytics:** Use ggplot2 to provide instant visual breakdowns of local risks.

---

## 🛠️ Technologies Used
- **Core Language:** R
- **Web Framework:** `Shiny` (UI & Server)
- **Spatial Mapping:** `Leaflet` (Provider Tiles: CartoDB DarkMatter & Positron)
- **UI/UX Enhancement:** `bslib` (Bootstrap 5), `shinyWidgets` (Custom Toggles/Buttons)
- **Data Visuals:** `ggplot2`
- **API Communication:** `httr` & `jsonlite` (Nominatim OpenStreetMap API)
- **Data Manipulation:** `tidyverse`

---

## ⚙️ Features

### 🗺️ Dynamic Spatial Intelligence
- **Coordinate Capture:** Tracks exact Latitude and Longitude of user clicks.
- **Reverse Geocoding:** Calls the OpenStreetMap API to identify the exact name (e.g., Nagpur, Pune, Gondia) of the clicked location.

### 🌫️ Pollution (AQI) Analysis Mode
- **Simulated Real-Time AQI:** Generates a localized AQI score (0–500).
- **Risk Classification:** Categories range from "Good" to "Severe" based on Indian NAAQS standards.

### 🚔 Crime Density Analysis Mode
- **Categorical Breakdown:** Provides a localized "Crime Index."
- **Visualization:** Shows a multi-category breakdown including Theft, Assault, Cybercrime, and Fraud.

### 🎨 State-Dependent UI
- **Theme Toggle:** Switch between "Dark Mode" and "Light Mode" with high-contrast CSS fixes.
- **Mode Persistence:** Visual indicators (checked icons) show whether the user is in Pollution or Crime analysis state.

---

## 🧠 Working Principle

1. **User Interaction:** The user selects a mode (Crime/Pollution) and clicks a point on the map.
2. **Data Acquisition:** The app captures the coordinates and sends a GET request to the Nominatim API to retrieve the human-readable address.
3. **Logic Processing:** A mathematical simulation engine generates a risk score based on coordinate data and the selected analysis mode.
4. **Reactive Rendering:** The map displays a popup at the click point, and the sidebar instantly updates with a `ggplot2` chart specific to that location.

---

## 🚀 How to Run

1. **Install required packages:**
   ```r
   install.packages(c("shiny", "leaflet", "bslib", "tidyverse", "ggplot2", "shinyWidgets", "httr"))
   Launch the App: Open app.R in RStudio and click Run App.
2. Launch the App: Open app.R in RStudio and click Run App.
3. Connectivity: Ensure you have an active internet connection for the API geocoding and map tiles to function correctly.
