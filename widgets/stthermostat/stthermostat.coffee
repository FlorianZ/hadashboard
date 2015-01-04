class Dashing.Stthermostat extends Dashing.ClickableWidget
  constructor: ->
    super
    @queryState()

  @accessor 'temperature',
    get: -> if @_temperature then Math.round(@_temperature) else 0
    set: (key, value) -> @_temperature = value

  @accessor 'setpoint',
    get: -> if @_setpoint then Math.round(@_setpoint) else 0
    set: (key, value) -> @_setpoint = value

  plusSetpoint: ->
    newSetpoint = parseInt(@get('setpoint'))+1
    if newSetpoint == 1
      newSetpoint = 0
    else if newSetpoint > 90
      newSetpoint = 90
    @set 'setpoint', newSetpoint
    return @get('setpoint')

  minusSetpoint: ->
    newSetpoint = parseInt(@get('setpoint'))-1
    if newSetpoint == -1
      newSetpoint = 0
    else if newSetpoint < 50
      newSetpoint = 50
    @set 'setpoint', newSetpoint
    return @get('setpoint')

  setpointUp: ->
    newSetpoint = @plusSetpoint()
    $.post '/smartthings/dispatch',
      deviceType: 'thermostatSetpoint',
      deviceId: @get('device'),
      setpoint: newSetpoint,
      (data) =>
        json = JSON.parse data


  setpointDown: ->
    newSetpoint = @minusSetpoint()
    $.post '/smartthings/dispatch',
      deviceType: 'thermostatSetpoint',
      deviceId: @get('device'),
      setpoint: newSetpoint,
      (data) =>
        json = JSON.parse data

  queryState: ->
    $.get '/smartthings/dispatch',
      widgetId: @get('id'),
      deviceType: 'thermostat',
      deviceId: @get('device')
      (data) =>
        json = JSON.parse data
        @set 'temperature', json.temperature
        @set 'setpoint', json.setpoint

  ready: ->

  onData: (data) ->

  onClick: (event) ->
    if event.target.id == "setpoint-down"
      @setpointDown()
    else if event.target.id == "setpoint-up"
      @setpointUp()
  
