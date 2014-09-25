class Dashing.Stcontact extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? "Unknown"
    set: (key, value) -> @_state = value

  @accessor 'icon',
    get: -> @_state == 'open' ? 'expand' : 'compress'
    set: Batman.Property.defaultAccessor.set

  updateBackgroundColor: ->
    if @get('state') == 'open'
      $(@node).css 'background-color', '#42C873'
    else
      $(@node).css 'background-color', '#888888'

  queryState: ->
    $.get '/smartthings/dispatch',
      widgetId: @get('id'),
      deviceType: 'contact',
      deviceId: @get('device')
      (data) =>
        json = JSON.parse data
        @set 'state', json.state
        @updateBackgroundColor()

  ready: ->

  onData: (data) ->
