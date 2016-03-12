class Dashing.Ohalert extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> (@_state) ? "Unknown"
    set: (key, value) -> @_state = value.toLowerCase()

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
        @set 'state', json.state

  ready: ->
    @setCSSClass(@get('state'))
    

  onData: (data) ->
    @setCSSClass(@get('state'))

    $(@node).fadeOut().fadeIn()  
    
  
  setCSSClass: (status) ->
    if status
      # clear existing "state-*" classes
      $(@get('node')).attr 'class', (i,c) ->
        c.replace /\bstate-\S+/g, ''

      #Add new class based on status
      $(@node).addClass "state-#{status}"
