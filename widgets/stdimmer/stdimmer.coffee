class Dashing.Stdimmer extends Dashing.Widget
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
    if @get('state') == 'on' then 'dimmer-icon-on' else 'dimmer-icon-off' 

  plusLevel: ->
    newLevel = parseInt(@get('level'))+10
    if newLevel > 100
      newLevel = 100
    else if newLevel < 0
      newLevel = 0
    @set 'level', newLevel
    return @get('level')

  minusLevel: ->
    newLevel = parseInt(@get('level'))-10
    if newLevel > 100
      newLevel = 100
    else if newLevel < 0
      newLevel = 0
    @set 'level', newLevel
    return @get('level')

  levelUp: ->
    newLevel = @plusLevel()
    $.post '/smartthings/dispatch',
      deviceType: 'dimmerLevel',
      deviceId: @get('device'),
      command: newLevel,
      (data) =>
        json = JSON.parse data


  levelDown: ->
    newLevel = @minusLevel()
    $.post '/smartthings/dispatch',
      deviceType: 'dimmerLevel',
      deviceId: @get('device'),
      command: newLevel,
      (data) =>
        json = JSON.parse data

  toggleState: ->
    newState = if @get('state') == 'on' then 'off' else 'on'
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

  onClick: (node, event) ->
    dataSpot = event.toElement.className
    if dataSpot == "fa fa-minus"
      @levelDown()
    else if dataSpot == "fa fa-plus"
      @levelUp()
    else if dataSpot == "toggle-area"
      @postState()