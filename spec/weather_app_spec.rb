require 'spec_helper'
require_relative '../weather_app'
require 'json'

RSpec.describe WeatherApp do
  let(:app) { WeatherApp.new }
  
  describe '#initialize' do
    it 'sets the API key' do
      expect(app.instance_variable_get(:@api_key)).to eq('07d51ae6758bd4024e999acebb93fba5')
    end
  end
  
  describe '#run' do
    context 'when no arguments provided' do
      it 'shows help' do
        expect { app.run([]) }.to output(/Weather App - Terminal weather information/).to_stdout
      end
    end
    
    context 'when --help flag is provided' do
      it 'shows help' do
        expect { app.run(['--help']) }.to output(/Weather App - Terminal weather information/).to_stdout
      end
    end
    
    context 'when -h flag is provided' do
      it 'shows help' do
        expect { app.run(['-h']) }.to output(/Weather App - Terminal weather information/).to_stdout
      end
    end
    
    context 'when city name is provided' do
      it 'fetches and displays weather for single word city' do
        allow(app).to receive(:fetch_and_display_weather).with('London')
        app.run(['London'])
        expect(app).to have_received(:fetch_and_display_weather).with('London')
      end
      
      it 'fetches and displays weather for multi-word city' do
        allow(app).to receive(:fetch_and_display_weather).with('San Francisco')
        app.run(['San', 'Francisco'])
        expect(app).to have_received(:fetch_and_display_weather).with('San Francisco')
      end
    end
  end
  
  describe '#fetch_weather_data' do
    let(:success_response) { double('response', code: '200', body: '{"name": "London"}') }
    let(:not_found_response) { double('response', code: '404') }
    let(:unauthorized_response) { double('response', code: '401') }
    let(:rate_limit_response) { double('response', code: '429') }
    let(:error_response) { double('response', code: '500') }
    
    context 'successful API response' do
      it 'returns parsed JSON data' do
        allow(Net::HTTP).to receive(:get_response).and_return(success_response)
        result = app.send(:fetch_weather_data, 'London')
        expect(result).to eq({ 'name' => 'London' })
      end
    end
    
    context 'city not found' do
      it 'raises appropriate error' do
        allow(Net::HTTP).to receive(:get_response).and_return(not_found_response)
        expect { app.send(:fetch_weather_data, 'InvalidCity') }
          .to raise_error("City 'InvalidCity' not found. Please check the city name and try again.")
      end
    end
    
    context 'invalid API key' do
      it 'raises appropriate error' do
        allow(Net::HTTP).to receive(:get_response).and_return(unauthorized_response)
        expect { app.send(:fetch_weather_data, 'London') }
          .to raise_error("Invalid API key. Please check your OpenWeather API key.")
      end
    end
    
    context 'rate limit exceeded' do
      it 'raises appropriate error' do
        allow(Net::HTTP).to receive(:get_response).and_return(rate_limit_response)
        expect { app.send(:fetch_weather_data, 'London') }
          .to raise_error("API rate limit exceeded. Please try again later.")
      end
    end
    
    context 'generic HTTP error' do
      it 'raises appropriate error' do
        allow(Net::HTTP).to receive(:get_response).and_return(error_response)
        expect { app.send(:fetch_weather_data, 'London') }
          .to raise_error("Failed to fetch weather data. HTTP Error: 500")
      end
    end
    
    context 'network error' do
      it 'handles SocketError' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
        expect { app.send(:fetch_weather_data, 'London') }
          .to raise_error("Network error. Please check your internet connection.")
      end
      
      it 'handles Timeout::Error' do
        allow(Net::HTTP).to receive(:get_response).and_raise(Timeout::Error)
        expect { app.send(:fetch_weather_data, 'London') }
          .to raise_error("Network error. Please check your internet connection.")
      end
    end
  end
  
  describe '#fetch_and_display_weather' do
    context 'when successful' do
      it 'fetches and displays weather data' do
        weather_data = { 'name' => 'London' }
        allow(app).to receive(:fetch_weather_data).and_return(weather_data)
        allow(app).to receive(:display_weather)
        
        app.send(:fetch_and_display_weather, 'London')
        
        expect(app).to have_received(:fetch_weather_data).with('London')
        expect(app).to have_received(:display_weather).with(weather_data)
      end
    end
    
    context 'when error occurs' do
      it 'prints error message' do
        allow(app).to receive(:fetch_weather_data).and_raise(StandardError.new("Test error"))
        
        expect { app.send(:fetch_and_display_weather, 'London') }
          .to output("Error: Test error\n").to_stdout
      end
    end
  end
  
  describe '#display_weather' do
    it 'creates formatter and calls display' do
      weather_data = { 'name' => 'London' }
      formatter = double('formatter')
      allow(WeatherFormatter).to receive(:new).with(weather_data).and_return(formatter)
      allow(formatter).to receive(:display)
      
      app.send(:display_weather, weather_data)
      
      expect(WeatherFormatter).to have_received(:new).with(weather_data)
      expect(formatter).to have_received(:display)
    end
  end
end