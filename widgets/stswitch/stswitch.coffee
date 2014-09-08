class Dashing.Stswitch extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? 'off'
    set: (key, value) -> @_state = value

  @accessor 'icon',
    get: -> @['icon'] ? 'power-off'
    set: Batman.Property.defaultAccessor.set

  @accessor 'stateInverse', ->
    if @get('state') == 'on' then 'off' else 'on'

  updateBackgroundColor: ->
    if @get('state') == 'on'
      $(@node).css 'background-color', '#42C873'
    else
      $(@node).css 'background-color', '#888888'

  toggleState: ->
    newState = @get 'stateInverse'
    @set 'state', newState
    @updateBackgroundColor()
    return newState

  queryState: ->
    $.get '/smartthings/dispatch',
      widgetId: @get('id'),
      deviceType: 'switch',
      deviceId: @get('device')
      (data) =>
        json = JSON.parse data
        @set 'state', json.switch
        @updateBackgroundColor()

  postState: ->
    newState = @toggleState()
    $.post '/smartthings/dispatch',
      deviceType: 'switch',
      deviceId: @get('device'),
      command: newState,
      (data) =>
        json = JSON.parse data
        if json.error != 0
          @toggleState()

  ready: ->

  onData: (data) ->
    @updateBackgroundColor()

  onClick: (node, event) ->
    @postState()