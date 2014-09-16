class Dashing.Stpresence extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'value',
    get: -> @_value ? "Unknown"
    set: (key, value) -> @_value = value

  queryState: ->
    $.get '/smartthings/dispatch',
      widgetId: @get('id'),
      deviceType: 'presence',
      deviceId: @get('device')
      (data) =>
        json = JSON.parse data
        @set 'value', json.value

  ready: ->

  onData: (data) ->
