require 'oauth2'
require 'json'

#
# Object grants REST-ful access to a ST SmartApp endpoint. This
# object also handles authorization with SmartThings.
# 
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

  # Returns the url used for authorization
  def authorize()
    @client.auth_code.authorize_url(redirect_uri: @redirect_uri, scope: 'app')
  end

  # Given a previously acquired auth code, this will acquire the
  # authorization token for use with subsequent requests.
  def acquireToken(auth_code)
    @token = @client.auth_code.get_token(
      auth_code, 
      redirect_uri: @redirect_uri,
      scope: 'app')

    response = @token.get('/api/smartapps/endpoints')
    @endpoint = response.parsed()[0]['url']
  end

  # Make a request to the SmartApp endpoint. The verb shall be set to
  # :get or :post. data shall be a dictionary, which will be converted
  # to a JSON object in the request.
  def request(verb, url, data)
    if not @token
      return
    end

    refreshToken()

    result = @token.request(
      verb, @endpoint + '/' + url, {
        body: JSON.generate(data), 
        headers: {'Content-Type'=>"application/json"} })
    result.body()
  end

  # Refresh the auth token, if it has expired.
  def refreshToken()
    if @token and @token.expired?
      @token = @token.refresh!
    end
  end

  private :refreshToken

end