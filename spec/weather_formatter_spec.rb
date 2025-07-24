require 'spec_helper'
require_relative '../weather_app'

RSpec.describe WeatherFormatter do
  let(:sample_data) do
    {
      'name' => 'London',
      'sys' => { 'country' => 'GB' },
      'main' => {
        'temp' => 15.5,
        'feels_like' => 14.2,
        'humidity' => 72,
        'pressure' => 1013
      },
      'weather' => [
        {
          'main' => 'Clouds',
          'description' => 'overcast clouds'
        }
      ],
      'wind' => {
        'speed' => 4.5,
        'deg' => 230
      }
    }
  end
  
  let(:formatter) { WeatherFormatter.new(sample_data) }
  
  describe '#display' do
    it 'outputs formatted weather information' do
      expected_output = /London, GB.*Temperature: 15.5°C \(59.9°F\).*Overcast clouds.*Feels like: 14.2°C/m
      expect { formatter.display }.to output(expected_output).to_stdout
    end
  end
  
  describe '#format_location' do
    it 'formats location with emoji and country code' do
      expect(formatter.send(:format_location)).to eq('📍 London, GB')
    end
  end
  
  describe '#format_temperature' do
    it 'formats temperature in both Celsius and Fahrenheit' do
      expect(formatter.send(:format_temperature)).to eq('🌡️  Temperature: 15.5°C (59.9°F)')
    end
    
    it 'rounds temperature values correctly' do
      sample_data['main']['temp'] = 15.567
      expect(formatter.send(:format_temperature)).to eq('🌡️  Temperature: 15.6°C (60.1°F)')
    end
  end
  
  describe '#format_description' do
    it 'formats weather description with appropriate icon' do
      expect(formatter.send(:format_description)).to eq('☁️  Weather: Overcast clouds')
    end
  end
  
  describe '#format_feels_like' do
    it 'formats feels like temperature in both units' do
      expect(formatter.send(:format_feels_like)).to eq('🤔 Feels like: 14.2°C (57.6°F)')
    end
  end
  
  describe '#format_details' do
    it 'formats humidity and pressure' do
      expect(formatter.send(:format_details)).to eq('💧 Humidity: 72% | 🔵 Pressure: 1013 hPa')
    end
  end
  
  describe '#format_wind' do
    it 'formats wind speed and direction' do
      expect(formatter.send(:format_wind)).to eq('💨 Wind: 4.5 m/s (10.1 mph) from WSW')
    end
    
    context 'when wind direction is missing' do
      it 'handles nil wind direction' do
        sample_data['wind'].delete('deg')
        expect(formatter.send(:format_wind)).to eq('💨 Wind: 4.5 m/s (10.1 mph) ')
      end
    end
  end
  
  describe '#weather_icon' do
    it 'returns correct icon for different weather conditions' do
      expect(formatter.send(:weather_icon, 'Clear')).to eq('☀️ ')
      expect(formatter.send(:weather_icon, 'Clouds')).to eq('☁️ ')
      expect(formatter.send(:weather_icon, 'Rain')).to eq('🌧️ ')
      expect(formatter.send(:weather_icon, 'Drizzle')).to eq('🌦️ ')
      expect(formatter.send(:weather_icon, 'Thunderstorm')).to eq('⛈️ ')
      expect(formatter.send(:weather_icon, 'Snow')).to eq('❄️ ')
      expect(formatter.send(:weather_icon, 'Mist')).to eq('🌫️ ')
      expect(formatter.send(:weather_icon, 'Fog')).to eq('🌫️ ')
      expect(formatter.send(:weather_icon, 'Unknown')).to eq('🌤️ ')
    end
  end
  
  describe '#wind_direction' do
    it 'converts degrees to compass direction' do
      expect(formatter.send(:wind_direction, 0)).to eq('from NNE')
      expect(formatter.send(:wind_direction, 45)).to eq('from ENE')
      expect(formatter.send(:wind_direction, 90)).to eq('from ESE')
      expect(formatter.send(:wind_direction, 135)).to eq('from SSE')
      expect(formatter.send(:wind_direction, 180)).to eq('from SSW')
      expect(formatter.send(:wind_direction, 225)).to eq('from WSW')
      expect(formatter.send(:wind_direction, 270)).to eq('from WNW')
      expect(formatter.send(:wind_direction, 315)).to eq('from NNW')
      expect(formatter.send(:wind_direction, 360)).to eq('from NNE')
    end
    
    it 'handles nil degrees' do
      expect(formatter.send(:wind_direction, nil)).to eq('')
    end
  end
end