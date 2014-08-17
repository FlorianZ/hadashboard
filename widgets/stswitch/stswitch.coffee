class Dashing.Stswitch extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? "off"
    set: (key, value) -> @_state = value

  @accessor 'state-icon', ->
    if @get('state') == 'on' then 'icon-lightbulb' else 'icon-lightbulb'

  @accessor 'stateInverse', ->
    if @get('state') == 'on' then 'off' else 'on'

  updateBackgroundColor: ->
    if @get('state') == 'on'
      $(@node).css 'background-color', '#42C873'
    else
      $(@node).css 'background-color', '#888888'

  queryState: ->
    $.get '/smartthings/dispatch',
      widgetId: @get('id'),
      deviceType: 'switch',
      deviceId: @get('device')
      (data) =>
        json = JSON.parse data
        @set 'state', json.switch
        @updateBackgroundColor()

  toggleState: ->
    newState = @get 'stateInverse'
    @set 'state', newState
    @updateBackgroundColor()
    return newState

  ready: ->

  onData: (data) ->
    @updateBackgroundColor()

  onClick: (node, event) ->
    newState = @toggleState()
    $.post '/smartthings/dispatch',
      deviceType: 'switch',
      deviceId: @get('device'),
      command: newState