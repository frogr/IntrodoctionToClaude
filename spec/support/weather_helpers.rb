module WeatherHelpers
  def load_fixture(filename)
    file_path = File.join(File.dirname(__FILE__), '..', 'fixtures', filename)
    JSON.parse(File.read(file_path))
  end
  
  def stub_weather_api_request(city, response_code, response_body = nil)
    response = double('response', code: response_code.to_s)
    response.stub(:body).and_return(response_body) if response_body
    allow(Net::HTTP).to receive(:get_response).and_return(response)
  end
  
  def capture_stdout(&block)
    original_stdout = $stdout
    $stdout = StringIO.new
    block.call
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end