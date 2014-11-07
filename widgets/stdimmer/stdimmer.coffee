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
    get: -> @['icon'] ? 'power-off'
    set: Batman.Property.defaultAccessor.set

  @accessor 'stateInverse', ->
    if @get('state') == 'on' then 'off' else 'on'

  updateBackgroundColor: ->
    if @get('state') == 'on'
      $(@node).css 'background-color', '#42C873'
    else
      $(@node).css 'background-color', '#72818B'

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
    newState = @get 'stateInverse'
    @set 'state', newState
    @updateBackgroundColor()
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
        @updateBackgroundColor()

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
    @updateBackgroundColor()

  onClick: (node, event) ->
    dataSpot = event.toElement.className
    if dataSpot == "fa fa-minus"
      @levelDown()
    else if dataSpot == "fa fa-plus"
      @levelUp()
    else if dataSpot == "fa fa-lightbulb-o" || dataSpot == "title"
      @postState()