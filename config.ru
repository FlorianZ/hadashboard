require 'openid/store/filesystem'
require 'omniauth/strategies/google_apps'
require 'dashing'

configure do
  set :auth_token, 'YOUR_AUTH_TOKEN'

  helpers do
    def protected!
      redirect '/auth/g' unless session[:user_id]
    end
  end

  use Rack::Session::Cookie
  use OmniAuth::Builder do
    provider :google_apps, :store => OpenID::Store::Filesystem.new('./tmp'), :name => 'g', :domain => 'hadashboard.heroku.com'
  end

  post '/auth/g/callback' do
    if auth = request.env['omniauth.auth'] 
      session[:user_id] = auth['info']['email']
      redirect '/'
    else
      redirect '/auth/failure'
    end
  end

  get '/auth/failure' do
    'Authentication failure.'
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application