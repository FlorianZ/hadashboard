class Dashing.Ohpresence extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? "Unknown"
    set: (key, value) -> @_state = value

  @accessor 'icon',
    get: -> if @get('state') == 'present' then 'user' else 'times'
    set: Batman.Property.defaultAccessor.set

  @accessor 'icon-style', ->
    if @get('state') == 'present' then 'icon-present' else 'icon-absent'
  
  queryState: ->
    $.get '/openhab/dispatch',
      widgetId: @get('id'),
      deviceId: @get('device'),
      deviceType: 'presence'
      (data) =>
        json = JSON.parse data
        @set 'state', json.state

  ready: ->

  onData: (data) ->
