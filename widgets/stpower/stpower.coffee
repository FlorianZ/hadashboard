class Dashing.Stpower extends Dashing.Widget

  @accessor 'value', Dashing.AnimatedValue

  constructor: ->
    super
    @observe 'value', (value) ->
		$.get '/smartthings/dispatch',
		  widgetId: @get('id'),
		  deviceType: 'power',
		  deviceId: @get('device')
		  (data) =>
			json = JSON.parse data
			@set 'value', json.value

  ready: ->
	meter = $(@node).find(".meter")
    meter.attr("data-bgcolor", meter.css("background-color"))
    meter.attr("data-fgcolor", meter.css("color"))
    meter.knob()

  onData: (data) ->
