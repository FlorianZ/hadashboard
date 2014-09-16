class Dashing.Stmeter extends Dashing.Widget

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
    stmeter = $(@get('id')).find(".stmeter")
    stmeter.attr("data-bgcolor", stmeter.css("background-color"))
    stmeter.attr("data-fgcolor", stmeter.css("color"))
    stmeter.knob()
