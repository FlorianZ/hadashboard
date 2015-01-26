require 'json'

# SmartApp credentials
client_id = ENV["ST_CLIENT_ID"]
# Keeping ST_API_KEY for compatibility (was renamed to ST_CLIENT_SECRET)
client_secret = ENV["ST_CLIENT_SECRET"] || ENV["ST_API_KEY"]

# Create a new STApp instance for communication with the SmartApp
app = STApp.new(client_id, client_secret)

def redirect_uri(request)
  request.base_url + '/smartthings/oauth/callback'
end

before do
  if request.request_method == "POST" and request.content_type=="application/json"
    body_params = request.body.read
    parsed = body_params && body_params.length > 1 ? JSON.parse(body_params) : nil
    params.merge!(parsed) unless parsed.nil?
  end
end

# Must be called to authenticate with SmartThings, at least once
get '/smartthings/authorize' do
  protected!
  redirect app.authorize(redirect_uri(request))
end

# Authentication callback for SmartThings
get '/smartthings/oauth/callback' do
  protected!
  app.acquireToken(redirect_uri(request), params[:code])
  app.request(:post, 'v1/configure', {
    dashingURI: request.base_url,
    dashingAuthToken: settings.auth_token})
  redirect '/'
end

# Dispatch requests to the SmartApp endpoint
get '/smartthings/dispatch' do
  protected!
  app.request(:get, params['path'], params)
end

post '/smartthings/dispatch' do
  protected!
  app.request(:post, params['path'], params)
end

# Update the weather ever so often
SCHEDULER.every '15m', :first_in => 0 do |job|
  # Current weather
  weather = app.request(:get, 'v1/info/weather', { feature: 'conditions' })

  # Forecast (today & tomorrow)
  forecast = app.request(:get, 'v1/info/weather', { feature: 'forecast' })
  
  # Emit the event
  if weather and forecast
    data = JSON.parse(weather).merge JSON.parse(forecast)
    send_event('weather', {
      now_temp: data["current_observation"]["temp_f"],
      humidity: data["current_observation"]["relative_humidity"],
      wind_speed: data["current_observation"]["wind_mph"],
      wind_speed_gust: data["current_observation"]["wind_gust_mph"],
      wind_dir: data["current_observation"]["wind_dir"],
      temp_low: data["forecast"]["simpleforecast"]["forecastday"][0]["low"]["fahrenheit"],
      temp_high: data["forecast"]["simpleforecast"]["forecastday"][0]["high"]["fahrenheit"],
      icon: data["forecast"]["simpleforecast"]["forecastday"][0]["icon"],
      precip: data["forecast"]["simpleforecast"]["forecastday"][0]["pop"],
      tomorrow_temp_low: data["forecast"]["simpleforecast"]["forecastday"][1]["low"]["fahrenheit"],
      tomorrow_temp_high: data["forecast"]["simpleforecast"]["forecastday"][1]["high"]["fahrenheit"],
      tomorrow_icon: data["forecast"]["simpleforecast"]["forecastday"][1]["icon"],
      tomorrow_precip: data["forecast"]["simpleforecast"]["forecastday"][1]["pop"]})
  end
end