class Dashing.Ohcontact extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? "Unknown"
    set: (key, value) -> @_state = value

  @accessor 'icon',
    get: -> if (@get('state') == 'open' || @get('state') == 'on') then 'expand' else 'compress'
    set: Batman.Property.defaultAccessor.set

  @accessor 'icon-style', ->
    if (@get('state') == 'open' || @get('state') == 'on') then 'icon-open' else 'icon-closed'

  queryState: ->
    $.get '/openhab/dispatch',
      widgetId: @get('id'),
      deviceId: @get('device'),
      deviceType: 'contact'
      (data) =>
        json = JSON.parse data
        @set 'state', json.state.toLowerCase()

  ready: ->


  onData: (data) ->
  	@set 'state', @get('state').toLowerCase() #openHAB states may come through in upper case, so reset property here as well

