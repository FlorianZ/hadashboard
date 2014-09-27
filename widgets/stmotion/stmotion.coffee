class Dashing.Stmotion extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? "Unknown"
    set: (key, value) -> @_state = value

  @accessor 'icon',
    get: -> if @get('state') == 'active' then 'exchange' else 'reorder'
    set: Batman.Property.defaultAccessor.set

  updateBackgroundColor: ->
    if @get('state') == 'active'
      $(@node).css 'background-color', '#42C873'
    else
      $(@node).css 'background-color', '#888888'

  queryState: ->
    $.get '/smartthings/dispatch',
      widgetId: @get('id'),
      deviceType: 'motion',
      deviceId: @get('device')
      (data) =>
        json = JSON.parse data
        @set 'state', json.state
        @updateBackgroundColor()

  ready: ->

  onData: (data) ->
    @updateBackgroundColor()
