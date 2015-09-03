class Dashing.Ohswitch extends Dashing.ClickableWidget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? 'OFF'
    set: (key, value) -> @_state = value

  @accessor 'icon',
    get: -> if @['icon'] then @['icon'] else
      if @get('state') == 'ON' then @get('iconon') else @get('iconoff')
    set: Batman.Property.defaultAccessor.set

  @accessor 'iconon',
    get: -> @['iconon'] ? 'circle'
    set: Batman.Property.defaultAccessor.set

  @accessor 'iconoff',
    get: -> @['iconoff'] ? 'circle-thin'
    set: Batman.Property.defaultAccessor.set

  @accessor 'icon-style', ->
    if @get('state') == 'ON' then 'switch-icon-on' else 'switch-icon-off'    

  toggleState: ->
    newState = if @get('state') == 'ON' then 'OFF' else 'ON'
    @set 'state', newState
    return newState

  queryState: ->
    $.get '/openhab/dispatch',
      widgetId: @get('id'),
      deviceId: @get('device'),
      deviceType: 'switch'
      (data) =>
        json = JSON.parse data
        @set 'state', json.state

  postState: ->
    newState = @toggleState()
    $.post '/openhab/dispatch',
      deviceId: @get('device'),
      command: newState     

  ready: ->

  onClick: (event) ->
    @postState()
