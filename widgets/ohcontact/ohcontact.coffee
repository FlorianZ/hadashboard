class Dashing.Ohcontact extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? "Unknown"
    set: (key, value) -> @_state = value

  @accessor 'icon',
    get: -> if @get('state') == 'open' then 'expand' else 'compress'
    set: Batman.Property.defaultAccessor.set

  @accessor 'icon-style', ->
    if (@get('state').toUpperCase() == 'OPEN' || @get('state') == 'ON') then 'icon-open' else 'icon-closed'

  queryState: ->
    $.get '/openhab/dispatch',
      widgetId: @get('id'),
      deviceId: @get('device'),
      deviceType: 'contact'
      (data) =>
        json = JSON.parse data
        @set 'state', json.state

  ready: ->
    @setColor(@get('state'))

  onData: (data) ->
    # Handle incoming data
    # You can access the html node of this widget with `@node`
    # Example: $(@node).fadeOut().fadeIn() will make the node flash each time data comes in.
    @setColor(@get('state'))
    $(@node).fadeOut().fadeIn()  

  setColor: (status) ->
    if status
      switch status.toUpperCase()
          when 'RUN' then $(@node).css("background-color", "#29a334") #green
          when 'FAIL' then $(@node).css("background-color", "#b80028") #red
          when 'PEND' then $(@node).css("background-color", "#ec663c") #orange
          when 'HOLD' then $(@node).css("background-color", "#4096ee") #blue
          when 'OPEN' then $(@node).css("background-color", "#b80028") #red
          when 'CLOSED' then $(@node).css("background-color", "#333") #default