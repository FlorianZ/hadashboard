require 'openid/store/filesystem'
require 'omniauth-google-oauth2'
require 'dashing'

configure do
  # set :auth_token, 'YOUR_AUTH_TOKEN'
  set :auth_token, ENV["DASHING_AUTH_TOKEN"]
  set :user, 'florian.zitzelsberger@gmail.com'

  helpers do
    def protected!
      if ENV["GOOGLE_CLIENT_ID"]
        redirect '/auth/google' unless session[:user_id] == settings.user
      end
    end
  end

  use Rack::Session::Cookie
  use OmniAuth::Builder do
    provider OmniAuth::Strategies::GoogleOauth2,
      ENV["GOOGLE_CLIENT_ID"],
      ENV["GOOGLE_CLIENT_SECRET"],
      :store => OpenID::Store::Filesystem.new('./tmp'),
      :name => 'google',
      :scope => 'email',
      :provider_ignores_state => true
  end

  get '/auth/google/callback' do
    if auth = request.env['omniauth.auth']
      if auth['info']['email'] == settings.user
        session[:user_id] = auth['info']['email']
        redirect '/'
      else
        redirect '/auth/bad'
      end
    else
      redirect '/auth/failure'
    end
  end

  get '/auth/failure' do
    "Authentication failure."
  end

  get '/auth/bad' do
    "Access denied."
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application