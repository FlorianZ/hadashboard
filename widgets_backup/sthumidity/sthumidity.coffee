class Dashing.Sthumidity extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'value',
    get: -> if @_value then Math.floor(@_value) else 0
    set: (key, value) -> @_value = value

  queryState: ->
    $.get '/smartthings/dispatch',
      widgetId: @get('id'),
      deviceType: 'humidity',
      deviceId: @get('device')
      (data) =>
        json = JSON.parse data
        @set 'value', json.value

  ready: ->

  onData: (data) ->
