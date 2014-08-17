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

SCHEDULER.every '5m', :first_in => 0 do |job|
  # temps = app.request(:get, 'temperature', {})
  # temps.each do |key, value|
  #   send_event(value[:widgetId], temps.select{|k,v| k != 'widgetId'})
  # end
end