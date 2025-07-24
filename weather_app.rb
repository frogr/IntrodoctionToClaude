#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'

class WeatherApp
  API_BASE_URL = 'https://api.openweathermap.org/data/2.5/weather'
  
  def initialize
    @api_key = '07d51ae6758bd4024e999acebb93fba5'
  end
  
  def run(args)
    if args.empty? || args.include?('--help') || args.include?('-h')
      show_help
      return
    end
    
    city = args.join(' ')
    
    unless @api_key
      puts "Error: OpenWeather API key not found!"
      puts "Please set OPENWEATHER_API_KEY environment variable or create a .weather_config file"
      return
    end
    
    fetch_and_display_weather(city)
  end
  
  private
  
  def load_api_key_from_config
    config_file = File.join(Dir.home, '.weather_config')
    return nil unless File.exist?(config_file)
    
    File.read(config_file).strip
  rescue
    nil
  end
  
  def fetch_and_display_weather(city)
    weather_data = fetch_weather_data(city)
    display_weather(weather_data)
  rescue => e
    puts "Error: #{e.message}"
  end
  
  def fetch_weather_data(city)
    uri = URI(API_BASE_URL)
    params = {
      q: city,
      appid: @api_key,
      units: 'metric'
    }
    uri.query = URI.encode_www_form(params)
    
    response = Net::HTTP.get_response(uri)
    
    case response.code
    when '200'
      JSON.parse(response.body)
    when '404'
      raise "City '#{city}' not found. Please check the city name and try again."
    when '401'
      raise "Invalid API key. Please check your OpenWeather API key."
    when '429'
      raise "API rate limit exceeded. Please try again later."
    else
      raise "Failed to fetch weather data. HTTP Error: #{response.code}"
    end
  rescue SocketError, Timeout::Error
    raise "Network error. Please check your internet connection."
  end
  
  def display_weather(data)
    formatter = WeatherFormatter.new(data)
    formatter.display
  end
  
  def show_help
    puts <<~HELP
      Weather App - Terminal weather information powered by OpenWeather API
      
      Usage:
        ruby weather_app.rb <city_name>
        ruby weather_app.rb <city_name,country_code>
        
      Examples:
        ruby weather_app.rb "San Francisco"
        ruby weather_app.rb "London,UK"
        ruby weather_app.rb Tokyo
        ruby weather_app.rb "New York"
        
      Options:
        --help, -h    Show this help message
        
      Configuration:
        Set your OpenWeather API key using one of these methods:
        1. Environment variable: export OPENWEATHER_API_KEY=your_api_key
        2. Config file: echo "your_api_key" > ~/.weather_config
        
      Get your free API key at: https://openweathermap.org/api
    HELP
  end
end

class WeatherFormatter
  def initialize(data)
    @data = data
  end
  
  def display
    puts "\n" + "=" * 50
    puts format_location
    puts "=" * 50
    
    puts "\n" + format_temperature
    puts format_description
    puts format_feels_like
    
    puts "\n" + format_details
    puts format_wind
    
    puts "=" * 50
  end
  
  private
  
  def format_location
    "📍 #{@data['name']}, #{@data['sys']['country']}"
  end
  
  def format_temperature
    temp_c = @data['main']['temp'].round(1)
    temp_f = (temp_c * 9/5 + 32).round(1)
    "🌡️  Temperature: #{temp_c}°C (#{temp_f}°F)"
  end
  
  def format_description
    desc = @data['weather'][0]['description'].capitalize
    icon = weather_icon(@data['weather'][0]['main'])
    "#{icon} Weather: #{desc}"
  end
  
  def format_feels_like
    feels_c = @data['main']['feels_like'].round(1)
    feels_f = (feels_c * 9/5 + 32).round(1)
    "🤔 Feels like: #{feels_c}°C (#{feels_f}°F)"
  end
  
  def format_details
    humidity = @data['main']['humidity']
    pressure = @data['main']['pressure']
    "💧 Humidity: #{humidity}% | 🔵 Pressure: #{pressure} hPa"
  end
  
  def format_wind
    speed_ms = @data['wind']['speed']
    speed_mph = (speed_ms * 2.237).round(1)
    direction = wind_direction(@data['wind']['deg'])
    "💨 Wind: #{speed_ms} m/s (#{speed_mph} mph) #{direction}"
  end
  
  def weather_icon(condition)
    case condition.downcase
    when 'clear' then '☀️ '
    when 'clouds' then '☁️ '
    when 'rain' then '🌧️ '
    when 'drizzle' then '🌦️ '
    when 'thunderstorm' then '⛈️ '
    when 'snow' then '❄️ '
    when 'mist', 'fog' then '🌫️ '
    else '🌤️ '
    end
  end
  
  def wind_direction(degrees)
    return '' unless degrees
    
    directions = %w[N NNE NE ENE E ESE SE SSE S SSW SW WSW W WNW NW NNW]
    index = ((degrees + 11.25) / 22.5).round % 16
    "from #{directions[index]}"
  end
end

if __FILE__ == $0
  app = WeatherApp.new
  app.run(ARGV)
end