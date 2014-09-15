class Dashing.Stpower extends Dashing.Widget

  @accessor 'value', Dashing.AnimatedValue

  constructor: ->
    super
    @queryState()
	@observe 'value', (value) ->
		$(@node).find(".stpower").val(value).trigger('change')
  
  queryState: ->
	$.get '/smartthings/dispatch',
	  widgetId: @get('id'),
	  deviceType: 'power',
	  deviceId: @get('device')
	  (data) =>
		json = JSON.parse data
		@set 'value', json.value

  ready: ->
	stpower = $(@node).find(".stpower")
    stpower.attr("data-bgcolor", stpower.css("background-color"))
    stpower.attr("data-fgcolor", stpower.css("color"))
    stpower.knob()

  onData: (data) ->
