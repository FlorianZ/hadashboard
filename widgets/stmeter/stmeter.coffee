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
    Stmeter = $(@node).find(".stmeter")
    Stmeter.attr("data-bgcolor", Stmeter.css("background-color"))
    Stmeter.attr("data-fgcolor", Stmeter.css("color"))
    Stmeter.knob()