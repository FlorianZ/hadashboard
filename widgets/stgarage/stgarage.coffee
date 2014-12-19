class Dashing.Stgarage extends Dashing.ClickableWidget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? 'open'
    set: (key, value) -> @_state = value

  @accessor 'icon',
    get: -> 'car'
    set: Batman.Property.defaultAccessor.set

  @accessor 'icon-style', ->
    if @get('state') == 'open' then icon = 'icon-open'
    if @get('state') == 'closed' then icon = 'icon-closed'
    if @get('state') == 'opening' then icon = 'icon-opening'
    if @get('state') == 'closing' then icon = 'icon-closing'
    return icon

  toggleState: ->
    newState = if @get('state') == 'open' then 'close' else 'open'
    @set 'state', newState
    return newState

  queryState: ->
    $.get '/smartthings/dispatch',
      widgetId: @get('id'),
      deviceType: 'garage',
      deviceId: @get('device')
      (data) =>
        json = JSON.parse data
        @set 'state', json.state

  postState: ->
    newState = @toggleState()
    $.post '/smartthings/dispatch',
      deviceType: 'garage',
      deviceId: @get('device'),
      command: newState,
      (data) =>
        json = JSON.parse data
        if json.error != 0
          @toggleState()

  ready: ->

  onData: (data) ->

  onClick: (event) ->
    @postState()

