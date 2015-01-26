class Dashing.Stswitch extends Dashing.DeviceWidget
  constructor: ->
    super 'switch'

  @accessor 'state',
    get: -> @_state ? 'off'
    set: (key, value) -> @_state = value

  @accessor 'icon',
    get: -> if @['icon'] then @['icon'] else
      if @get 'state'  == 'on' then @get 'iconon' else @get 'iconoff'
    set: Batman.Property.defaultAccessor.set

  @accessor 'iconon',
    get: -> @['iconon'] ? 'circle'
    set: Batman.Property.defaultAccessor.set

  @accessor 'iconoff',
    get: -> @['iconoff'] ? 'circle-thin'
    set: Batman.Property.defaultAccessor.set

  @accessor 'icon-style', ->
    if @get 'state' == 'on' then 'switch-icon-on' else 'switch-icon-off'    

  toggleState: ->
    @set 'state', if @get 'state' == 'on' then 'off' else 'on'

  onData: (data) ->
    @set 'state', getDeviceAttribute 'switch'

  onClick: (event) ->
    @toggleState
    response = @executeDeviceCommand @get 'state'
    if response.error isnt 0
      @toggleState