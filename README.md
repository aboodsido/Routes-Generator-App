# Walking Routes App

A Flutter-based mobile application that generates looped walking routes based on the walking time provided by the user. The app calculates a target distance using an average walking speed (default: 1.4 m/s ≈ 5 km/h) and then generates an interesting route loop by creating a three-segment path (A → B → C → A) using the Google Directions API.

## Features

- **Time-Based Route Generation:**  
  Users can enter the desired walking time (in minutes), and the app converts it to an estimated distance.
  
- **Dynamic Route Creation:**  
  Generates a three-point loop route (A → B → C → A) with two distinct waypoints to ensure the return leg is different from the outbound path.
  
- **Google Maps Integration:**  
  Displays the generated walking route on an interactive Google Map.
  
- **State Management with Provider:**  
  Uses Provider to manage app state and handle location and route data efficiently.
  
- **Customizable & Extensible:**  
  Easily adjust average walking speed, waypoint generation logic, and route optimization as needed.

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- A valid **Google Maps API Key** with the following APIs enabled:
  - Maps SDK for Android
  - Maps SDK for iOS
  - Directions API
- Basic understanding of Flutter and Dart

## Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/aboodsido/Routes-Generator-App.git
