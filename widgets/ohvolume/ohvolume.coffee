class Dashing.Ohvolume extends Dashing.ClickableWidget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? '0'
    set: (key, value) -> @_state = value


  @accessor 'icon',
    get: -> if @['icon'] then @['icon'] else
      if parseInt(@get('state')) > 0 then @get('iconon') else @get('iconoff')
    set: Batman.Property.defaultAccessor.set

  @accessor 'iconon',
    get: -> @['iconon'] ? 'circle'
    set: Batman.Property.defaultAccessor.set

  @accessor 'iconoff',
    get: -> @['iconoff'] ? 'circle-thin'
    set: Batman.Property.defaultAccessor.set

  @accessor 'icon-style', ->
    if parseInt(@get('state')) >0 then 'volume-icon-on' else 'volume-icon-off' 

  plusLevel: ->
    newLevel = parseInt(@get('state'))+5
    if newLevel > 100
      newLevel = 100
    else if newLevel < 0
      newLevel = 0
    @set 'state', newLevel
    return @get('state')

  minusLevel: ->
    newLevel = parseInt(@get('state'))-5
    if newLevel > 100
      newLevel = 100
    else if newLevel < 0
      newLevel = 0
    @set 'state', newLevel
    return @get('state')

  levelUp: ->
    newLevel = @plusLevel()
    $.post '/openhab/dispatch',
      deviceId: @get('device'),
      command: newLevel    

  levelDown: ->
    newLevel = @minusLevel()
    $.post '/openhab/dispatch',
      deviceId: @get('device'),
      command: newLevel     

  toggleState: ->
    newState = if @get('state') > 0  then '0' else '20'
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

  onData: (data) ->
    debugger

  onClick: (event) ->
    if event.target.id == "level-down"
      @levelDown()
    else if event.target.id == "level-up"
      @levelUp()
    else if event.target.id == "switch"
      @postState()
