require 'omniauth/strategies/heroku'
require 'dashing'

configure do
  set :auth_token, ENV["DASHING_AUTH_TOKEN"]
  set :user, ENV["HEROKU_OAUTH_EMAIL"]

  helpers do
    def protected!
      if settings.user
        redirect '/auth/heroku' unless session[:user_id] == settings.user
      else
        redirect '/auth/notset'
      end
    end
  end

  use Rack::Session::Cookie
  use OmniAuth::Builder do
    provider :heroku,
      ENV["HEROKU_OAUTH_ID"],
      ENV["HEROKU_OAUTH_SECRET"],
      fetch_info: true
  end

  get '/auth/heroku/callback' do
    if auth = request.env['omniauth.auth']
      if auth['info']['email'] == settings.user
        session[:user_id] = settings.user
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

  get '/auth/notset' do
    "Credentials not set."
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application