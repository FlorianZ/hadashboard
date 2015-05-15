require 'omniauth-heroku'
require 'dashing'

configure do
  # The auth token used by external clients to get API access to the
  # dashing widgets.
  set :auth_token, ENV["DASHING_AUTH_TOKEN"]

  # Email used for signing up to Heroku. This is used for authentication.
  set :user, ENV["HEROKU_OAUTH_EMAIL"]

helpers do

  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', 'P@22w0rd']
  end

end

  # Store the authenticated user name in session state
  use Rack::Session::Cookie, :secret => ENV["SESSION_SECRET"]

  # Authenticate with Heroku
  use OmniAuth::Builder do
    provider :heroku,
      ENV["HEROKU_OAUTH_ID"],
      ENV["HEROKU_OAUTH_SECRET"],
      fetch_info: true
  end

  # Heroku authentication callback.
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

  # Authentication failure. Indicates a configuration problem.
  get '/auth/failure' do
    "Authentication failure."
  end

  # Bad credentials. Indicates that the username, password or two-factor
  # auth code (if enabled) is incorrect.
  get '/auth/bad' do
    "Access denied."
  end

  # No authentication credentials have been set. HEROKU_OAUTH_EMAIL set?
  get '/auth/notset' do
    "Credentials not set."
  end

  # Restore the event history on load
  savedHistory = Setting.get('history')
  if savedHistory
    set :history, JSON.parse(savedHistory.value)
  end

  # Upong exiting, write the event history to persistent storage
  at_exit do
    savedHistory = Setting.first_or_create(:name => 'history')
    savedHistory.value = JSON.generate(settings.history)
    savedHistory.save
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
