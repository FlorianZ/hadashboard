#= require dashing.interactivewidget
#= require dashing.stappclient

class Dashing.DeviceWidget extends Dashing.InteractiveWidget

  subscribeToDevices: (devicesAndAttrs) ->
    widgetId = @get 'id'
    params = { widgets: {} }
    params.widgets[widgetId] = devicesAndAttrs
    Dashing.stAppClient.request 'post', 'subscribe', params,
      (data) =>
        json = JSON.parse data
        @receiveData json[widgetId]

  subscribeToDevice: (attrs) ->
    deviceKey = @get 'device'
    devicesAndAttrs = {}
    devicesAndAttrs[deviceKey] = [].concat attrs
    @subscribeToDevices devicesAndAttrs

  unsubscribeFromDevices: (devices = []) ->
    widgetId = @get 'id'
    params = { widgets: {} }
    params.widgets[widgetId] = [].concat devices
    Dashing.stAppClient.request 'post', 'unsubscribe', params

  executeDeviceCommands: (devicesAndCommands, callback = null) ->
    params = { devices: devicesAndCommands }
    Dashing.stAppClient.request 'post', 'execute', params,
      (data) =>
        if callback
          callback JSON.parse data

  executeDeviceCommand: (command, callback = null) ->
    commands = command
    if typeof command == 'string'
      commands = {}
      commands[command] = []
    deviceKey = @get 'device'
    devicesAndCommands = {}
    devicesAndCommands[deviceKey] = commands
    @executeDeviceCommands devicesAndCommands, callback

  getDeviceAttribute: (params) ->
    deviceKey =
      if typeof params is 'string'
      then @get 'device' else @get params.device
    attrName =
      if typeof params is 'string'
      then params else params.name
    @get(deviceKey)[attrName]