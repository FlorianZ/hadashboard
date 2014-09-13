require 'json'

# URI to the installed app root
host_uri = ENV["DASHING_URI"] || 'http://localhost:3030'

# SmartApp credentials
client_id = ENV["ST_CLIENT_ID"]
api_key = ENV["ST_API_KEY"]

# Create a new STApp instance for communication with the SmartApp
app = STApp.new(
  client_id, api_key,
  host_uri + '/smartthings/oauth/callback')

# Must be called to authenticate with SmartThings, at least once
get '/smartthings/authorize' do
  redirect app.authorize
end

# Authentication callback for SmartThings
get '/smartthings/oauth/callback' do
  app.acquireToken(params[:code])
  app.request(:post, 'config', {
    dashingURI: host_uri,
    dashingAuthToken: settings.auth_token})
  redirect '/'
end

# Dispatch requests to the SmartApp endpoint
get '/smartthings/dispatch' do
  app.request(:get, params['deviceType'], params)
end

post '/smartthings/dispatch' do
  app.request(:post, params['deviceType'], params)
end

# Update the weather ever so often
SCHEDULER.every '15m', :first_in => 1 do |job|
  # Current weather
  weather = app.request(:get, 'weather', {
    feature: 'conditions'})
  if weather
    weather = JSON.parse(weather)
    send_event('weather', {
      now_temp: weather["current_observation"]["temp_f"],
      humidity: weather["current_observation"]["relative_humidity"],
      wind_speed: weather["current_observation"]["wind_mph"],
      wind_speed_gust: weather["current_observation"]["wind_gust_mph"],
      wind_dir: weather["current_observation"]["wind_dir"]})
  end

  # Forecast (today & tomorrow)
  forecast = app.request(:get, 'weather', {
    feature: 'forecast'})
  if forecast
    forecast = JSON.parse(forecast)
    send_event('weather', {
      temp_low: forecast["forecast"]["simpleforecast"]["forecastday"][0]["low"]["fahrenheit"],
      temp_high: forecast["forecast"]["simpleforecast"]["forecastday"][0]["high"]["fahrenheit"],
      icon: forecast["forecast"]["simpleforecast"]["forecastday"][0]["icon"],
      precip: forecast["forecast"]["simpleforecast"]["forecastday"][0]["pop"],
      tomorrow_temp_low: forecast["forecast"]["simpleforecast"]["forecastday"][1]["low"]["fahrenheit"],
      tomorrow_temp_high: forecast["forecast"]["simpleforecast"]["forecastday"][1]["high"]["fahrenheit"],
      tomorrow_icon: forecast["forecast"]["simpleforecast"]["forecastday"][1]["icon"],
      tomorrow_precip: forecast["forecast"]["simpleforecast"]["forecastday"][1]["pop"]})
  end
end