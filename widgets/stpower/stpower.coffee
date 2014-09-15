class Dashing.Stpower extends Dashing.Widget

  @accessor 'value', Dashing.AnimatedValue

  constructor: ->
    super
    @queryState()
	@observe 'value', (value) ->
		$(@node).find(".meter").val(value).trigger('change')
  
  queryState: ->
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
