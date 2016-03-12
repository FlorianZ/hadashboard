class Dashing.Ohtext extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? "Unknown"
    set: (key, value) -> @_state = value
    
  queryState: ->
    $.get '/openhab/dispatch',
      widgetId: @get('id'),
      deviceId: @get('device'),
      deviceType: 'text'
      (data) =>
        json = JSON.parse data
        @set 'state', json.state

  ready: ->

  onData: (data) ->
