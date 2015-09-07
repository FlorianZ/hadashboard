class Dashing.Ohalert extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? "Unknown"
    set: (key, value) -> @_state = value

  @accessor 'isAlertState', ->
    (@get('state') == 'open' || @get('state') == 'on')

  @accessor 'icon',
    get: -> if (@get('isAlertState')) then 'expand' else 'compress'
    set: Batman.Property.defaultAccessor.set

  @accessor 'icon-style', ->
    if (@get('isAlertState')) then 'icon-open' else 'icon-closed'


  queryState: ->
    $.get '/openhab/dispatch',
      widgetId: @get('id'),
      deviceId: @get('device'),
      deviceType: 'contact'
      (data) =>
        json = JSON.parse data
        @set 'state', json.state.toLowerCase()

  ready: ->
    @setCSSClass(@get('state'))
    

  onData: (data) ->
    @set 'state', @get('state').toLowerCase() #openHAB states may come through in upper case, so reset property here as well
    @setCSSClass(@get('state'))
    $(@node).fadeOut().fadeIn()  
    
  
  setCSSClass: (status) ->
    if status
      #console.log("State: ", status)      

	    # clear existing "status-*" classes
      $(@get('node')).attr 'class', (i,c) ->
        c.replace /\bstatus-\S+/g, ''

      #Add new class based on status
      $(@node).addClass "status-#{status}"
