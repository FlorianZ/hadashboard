class Dashing.Ohroomstatus extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? "Unknown"
    set: (key, value) -> @_state = value

  @accessor 'temperature',
    get: -> if @_temperature then Math.floor(@_temperature) else 0
    set: (key, value) -> @_temperature = value

  @accessor 'icon',
    get: -> if @get('state') == 'open' then 'expand' else 'compress'
    set: Batman.Property.defaultAccessor.set

  @accessor 'icon-style', ->
    if (@get('state').toUpperCase() == 'OPEN' || @get('state') == 'ON') then 'icon-open' else 'icon-closed'

  queryState: ->
    $.get '/openhab/dispatch',
      widgetId: @get('id'),
      deviceId: @get('device'),
      deviceType: 'contact'
      (data) =>
        json = JSON.parse data
        @set 'state', json.state

  ready: ->

  onData: (data) ->
