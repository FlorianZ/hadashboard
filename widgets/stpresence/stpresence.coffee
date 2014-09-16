class Dashing.Stpresence extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? "Unknown"
    set: (key, value) -> @_state = value

  updateBackgroundColor: ->
    if @get('state') == 'present'
      $(@node).css 'background-color', '#ffa500'
    else
      $(@node).css 'background-color', '#888888'
	
  queryState: ->
    $.get '/smartthings/dispatch',
      widgetId: @get('id'),
      deviceType: 'presence',
      deviceId: @get('device')
      (data) =>
        json = JSON.parse data
        @set 'state', json.state.toUpperCase()
		@updateBackgroundColor()

  ready: ->

  onData: (data) ->
