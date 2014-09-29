class Dashing.Stlock extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? 'unlocked'
    set: (key, value) -> @_state = value

  @accessor 'icon',
    get: -> if @get('state') == 'unlocked' then 'unlock-alt' else 'lock'
    set: Batman.Property.defaultAccessor.set

  @accessor 'stateInverse', ->
    if @get('state') == 'locked' then 'unlock' else 'lock'

  updateBackgroundColor: ->
    if @get('state') == 'locked'
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
      deviceType: 'lock',
      deviceId: @get('device')
      (data) =>
        json = JSON.parse data
        @set 'state', json.state
        @updateBackgroundColor()

  postState: ->
    newState = @toggleState()
    $.post '/smartthings/dispatch',
      deviceType: 'lock',
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
