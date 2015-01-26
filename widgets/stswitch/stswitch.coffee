class Dashing.Stswitch extends Dashing.DeviceWidget

  ready: ->
    @subscribeToDevice 'switch'

  @accessor 'state',
    get: -> @['state'] ? 'off'
    set: (key, value) -> @['state'] = value

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

  toggleState: ->
    newState = if @get('state') == 'on' then 'off' else 'on'
    @set 'state', newState

  onData: (data) ->
    @set 'state', @getDeviceAttribute 'switch'

  onClick: (event) ->
    @toggleState()
    response = @executeDeviceCommand @get 'state', 
      (data) =>
        if data.error != 0
          alert data.error
          @toggleState()