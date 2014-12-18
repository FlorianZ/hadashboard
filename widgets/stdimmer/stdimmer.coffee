class Dashing.Stdimmer extends Dashing.ClickableWidget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? 'off'
    set: (key, value) -> @_state = value

  @accessor 'level',
    get: -> @_level ? '50'
    set: (key, value) -> @_level = value

  @accessor 'icon',
    get: -> if @['icon'] then @['icon'] else
      if @get('state') == 'on' then @get('iconon') else @get('iconoff')
    set: Batman.Property.defaultAccessor.set

  @accessor 'iconon',
    get: -> @['iconon'] ? 'circle'
    set: Batman.Property.defaultAccessor.set

  @accessor 'iconoff',
    get: -> @['iconoff'] ? 'circle-thin'
    set: Batman.Property.defaultAccessor.set

  @accessor 'icon-style', ->
    if @get('state') == 'on' then 'switch-icon-on' else 'switch-icon-off'

  @accessor 'stateInverse', ->
    if @get('state') == 'on' then 'off' else 'on'

  setLevel: ->
    @_level = event.target.value
    $.post '/smartthings/dispatch',
      deviceType: 'dimmer/level',
      deviceId: @get('device'),
      command: @_level,
      (data) =>
        json = JSON.parse data

  toggleState: ->
    newState = @get 'stateInverse'
    @set 'state', newState
    return newState

  queryState: ->
    $.get '/smartthings/dispatch',
      widgetId: @get('id'),
      deviceType: 'dimmer',
      deviceId: @get('device')
      (data) =>
        json = JSON.parse data
        @set 'state', json.state
        @set 'level', json.level

  postState: ->
    newState = @toggleState()
    $.post '/smartthings/dispatch',
      deviceType: 'dimmer',
      deviceId: @get('device'),
      command: newState,
      (data) =>
        json = JSON.parse data
        if json.error != 0
          @toggleState()

  ready: ->

  onData: (data) ->


  onClick: (event) ->
    if event.target.id == "dimmer"
      @setLevel(event)
    else if event.target.id == "switch"
      @postState()
