# 🌍 EcoGuard: India Intelligence Map

## 📌 Project Overview
EcoGuard is an interactive web application built using R Shiny that visualizes geographical intelligence across India. It allows users to click on any location and analyze Pollution (AQI) and Crime Density.

The system combines maps, API data, and visualization to provide a simple spatial intelligence dashboard.

---

## 🎯 Objectives
- Build an interactive map-based application  
- Visualize location-based data dynamically  
- Use APIs to fetch real location names  
- Simulate AQI and crime-related insights  
- Create a user-friendly dashboard  

---

## 🛠️ Technologies Used
- R Programming Language  
- Shiny  
- Leaflet  
- bslib  
- ggplot2  
- httr  
- tidyverse  

---

## ⚙️ Features

### 🗺️ Interactive Map
- Click anywhere on the map  
- Displays location name using reverse geocoding  

### 🌫️ Pollution (AQI) Analysis
- Generates AQI score based on coordinates  
- Displays risk levels (Low, Moderate, High, Severe)  

### 🚔 Crime Density Analysis
- Shows crime score for selected location  
- Displays breakdown:
  - Theft  
  - Assault  
  - Cybercrime  
  - Fraud  

### 🎨 Theme Toggle
- Switch between Dark Mode and Light Mode  

### 📊 Dynamic Visualization
- Graph updates instantly when switching modes  
- AQI → single bar chart  
- Crime → multi-category chart  

---

## 🧠 Working Principle

1. User clicks on map  
2. Latitude & Longitude are captured  
3. OpenStreetMap API is used to fetch location name  
4. Score is generated using a mathematical function  
5. Risk level is calculated  
6. Results are displayed on map and sidebar  

---

## 🔢 Score Logic
