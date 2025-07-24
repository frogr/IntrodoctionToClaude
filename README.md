# OpenWeather Terminal App

A Ruby command-line application that fetches and displays weather information using the OpenWeather API.

## Features

- Fetch current weather data for any city
- Display temperature in both Celsius and Fahrenheit
- Show weather conditions, humidity, pressure, and wind information
- Clean, formatted terminal output with weather icons
- Graceful error handling for invalid cities and network issues
- Flexible API key configuration

## Requirements

- Ruby (tested with Ruby 2.7+)
- OpenWeather API key (free tier available)

## Installation

1. Clone or download the `weather_app.rb` file
2. Make it executable:
   ```bash
   chmod +x weather_app.rb
   ```
3. Get your free API key from [OpenWeather](https://openweathermap.org/api)

## Configuration

Configure your API key using one of these methods:

### Method 1: Environment Variable
```bash
export OPENWEATHER_API_KEY=your_api_key_here
```

### Method 2: Config File
```bash
echo "your_api_key_here" > ~/.weather_config
```

## Usage

```bash
# Basic usage
ruby weather_app.rb "San Francisco"
ruby weather_app.rb London
ruby weather_app.rb "New York"

# With country code
ruby weather_app.rb "London,UK"
ruby weather_app.rb "Paris,FR"

# Show help
ruby weather_app.rb --help
```

## Example Output

```
==================================================
📍 London, GB
==================================================

🌡️  Temperature: 15.2°C (59.4°F)
☁️  Weather: Overcast clouds
🤔 Feels like: 14.8°C (58.6°F)

💧 Humidity: 72% | 🔵 Pressure: 1013 hPa
💨 Wind: 4.5 m/s (10.1 mph) from SW
==================================================
```

## Error Handling

The app handles various error scenarios:
- Invalid city names
- Network connection issues
- Invalid or missing API key
- API rate limits

## Dependencies

Uses only Ruby standard library:
- `net/http` for API requests
- `json` for parsing responses
- `uri` for URL handling