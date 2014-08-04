class Dashing.Stswitch extends Dashing.Widget

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

  ready: ->

  onData: (data) ->
    @updateBackgroundColor()

  onClick: (node, event) ->
    $.post '/smartthings/dispatch',
      widgetId: @get('id'),
      deviceType: 'switch',
      deviceId: @get('device'),
      command: @get('stateInverse')
      (data) =>
        @set 'state', @get 'stateInverse'
        @updateBackgroundColor()
        