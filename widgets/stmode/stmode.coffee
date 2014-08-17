class Dashing.Stmode extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'mode',
    get: -> @_mode ? "Unknown"
    set: (key, value) -> @_mode = value

  queryState: ->
    $.get '/smartthings/dispatch',
      widgetId: @get('id'),
      deviceType: 'mode'
      (data) =>
        json = JSON.parse data
        @set 'mode', json.mode

  ready: ->

  onData: (data) ->
