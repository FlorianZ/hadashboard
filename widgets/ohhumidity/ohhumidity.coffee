class Dashing.Ohhumidity extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'value',
    get: -> if @_value then Math.floor(@_value) else 0
    set: (key, value) -> @_value = value

  queryState: ->
    $.get '/openhab/dispatch',
      widgetId: @get('id'),
      deviceId: @get('device'),
      deviceType: 'humidity'
      (data) =>
        json = JSON.parse data
        @set 'value', json.state

  ready: ->

  onData: (data) ->
