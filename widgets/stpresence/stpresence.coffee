class Dashing.Stpresence extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? "Unknown"
    set: (key, value) -> @_state = value

  @accessor 'icon',
    get: -> if @get('state') == 'present' then 'user' else 'times'
    set: Batman.Property.defaultAccessor.set

  updateBackgroundColor: ->
    if @get('state') == 'present'
      $(@node).css 'background-color', '#42C873'
    else
      $(@node).css 'background-color', '#888888'
  
  queryState: ->
    $.get '/smartthings/dispatch',
      widgetId: @get('id'),
      deviceType: 'presence',
      deviceId: @get('device')
      (data) =>
        json = JSON.parse data
        @set 'state', json.state
        @updateBackgroundColor()

  ready: ->

  onData: (data) ->
