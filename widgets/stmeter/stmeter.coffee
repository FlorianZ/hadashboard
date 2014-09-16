class Dashing.Stmeter extends Dashing.Widget
  @accessor 'value', Dashing.AnimatedValue
  
  constructor: ->
    super
    @queryState()
    @observe 'value', (value) ->
      $(@node).find(".stmeter").val(value).trigger('change')
	
  queryState: ->
    $.get '/smartthings/dispatch',
    widgetId: @get('id'),
    deviceType: 'power',
    deviceId: @get('device')
    (data) =>
      json = JSON.parse data
      @set 'value', json.value

  ready: ->
    stmeter = $(@node).find(".stmeter")
    stmeter.attr("data-bgcolor", stmeter.css("background-color"))
    stmeter.attr("data-fgcolor", stmeter.css("color"))
    stmeter.knob()