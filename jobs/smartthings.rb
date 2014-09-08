require 'json'

host_uri = 'http://localhost:3030'
client_id = 'ef49b1d0-15ec-44cb-ba7e-820d519841fe'
api_key = '196c0d63-65b2-4ca0-99f7-ca05e7322021'
redirect_url = 'smartthings/oauth/callback'

app = STApp.new(client_id, api_key, host_uri + '/' + redirect_url)

get '/smartthings/authorize' do
  redirect app.authorize
end

get '/smartthings/oauth/callback' do
  app.acquireToken(params[:code])
  app.request(:post, 'config', {
    dashingURI: host_uri,
    dashingAuthToken: settings.auth_token})
  redirect '/'
end

get '/smartthings/dispatch' do
  app.request(:get, params['deviceType'], params)
end

post '/smartthings/dispatch' do
  app.request(:post, params['deviceType'], params)
end

SCHEDULER.every '15m', :first_in => 1 do |job|
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