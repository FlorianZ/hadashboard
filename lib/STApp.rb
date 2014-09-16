require 'oauth2'
require 'json'

#
# Object grants REST-ful access to a ST SmartApp endpoint. This
# object also handles authorization with SmartThings.
# 
class STApp
  def initialize(client_id, api_key, redirect_uri)
    @client = OAuth2::Client.new(client_id, api_key, {
      site: 'https://graph.api.smartthings.com',
      authorize_url: '/oauth/authorize',
      token_url: '/oauth/token'
    })

    @token = retrieveToken()
    @endpoint = getEndpoint(@token)
    @redirect_uri = redirect_uri
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
    storeToken(@token)

    @endpoint = getEndpoint(@token)
  end

  # Make a request to the SmartApp endpoint. The verb shall be set to
  # :get or :post. data shall be a dictionary, which will be converted
  # to a JSON object in the request.
  def request(verb, url, data)
    if not @token
      return
    end

    @token = refreshToken(@token)

    result = @token.request(
      verb, @endpoint + '/' + url, {
        body: JSON.generate(data), 
        headers: {'Content-Type'=>"application/json"} })
    result.body()
  end

  # Refresh the auth token, if it has expired.
  def refreshToken(token)
    if token and token.expired?
      token.refresh!
    else
      token
    end
  end

  # Retrieve the SmartApp endpoint
  def getEndpoint(token)
    if not token
      return nil
    end

    response = token.get('/api/smartapps/endpoints')
    response.parsed()[0]['url']
  end

  # Retrieve an existing token from persistent storage
  def retrieveToken()
    s = Setting.get('st_token')
    if s
      token = OAuth2::AccessToken.from_hash(
        @client,
        JSON.parse(s.value))
      refreshToken(token)   
    end
  end

  # Store a token in persistant storage
  def storeToken(token)
    Setting.first_or_create(
      { :name => 'st_token'},
      { :value => JSON.generate(token.to_hash) })
  end

  private :refreshToken, :getEndpoint, :retrieveToken, :storeToken

end