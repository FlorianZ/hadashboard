class Dashing.Stmotion extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? "Unknown"
    set: (key, value) -> @_state = value

  @accessor 'icon',
    get: -> if @get('state') == 'active' then 'exchange' else 'reorder'
    set: Batman.Property.defaultAccessor.set

  @accessor 'icon-style', ->
    if @get('state') == 'active' then 'icon-active' else 'icon-inactive'

  queryState: ->
    $.get '/smartthings/dispatch',
      widgetId: @get('id'),
      deviceType: 'motion',
      deviceId: @get('device')
      (data) =>
        json = JSON.parse data
        @set 'state', json.state

  ready: ->

  onData: (data) ->
