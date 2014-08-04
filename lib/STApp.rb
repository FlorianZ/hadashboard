require 'oauth2'
require 'json'

class STApp
  def initialize(client_id, api_key, redirect_uri)
    @token = nil
    @endpoint = nil
    @redirect_uri = redirect_uri
    @client = OAuth2::Client.new(client_id, api_key, {
      site: 'https://graph.api.smartthings.com',
      authorize_url: '/oauth/authorize',
      token_url: '/oauth/token'
    })
  end

  def authorize()
    @client.auth_code.authorize_url(redirect_uri: @redirect_uri, scope: 'app')
  end

  def acquireToken(auth_code)
    @token = @client.auth_code.get_token(
      auth_code, 
      redirect_uri: @redirect_uri,
      scope: 'app')

    response = @token.get('/api/smartapps/endpoints')
    @endpoint = response.parsed()[0]['url']
  end

  def request(verb, url, data)
    if not @token
      return
    end

    refreshToken()

    result = @token.request(
      verb, @endpoint + '/' + url, {
        body: JSON.generate(data), 
        headers: {'Content-Type'=>"application/json"} })
    result.parsed()
  end

  def refreshToken()
    if @token and @token.expired?
      @token.refresh!
    end
  end

  private :refreshToken

end