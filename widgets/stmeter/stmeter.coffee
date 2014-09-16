class Dashing.Stmeter extends Dashing.Widget
  constructor: ->
    super
    @queryState()
    @observe 'value', (value) ->
      $(@node).find(".stmeter").val(value).trigger('change')

  @accessor 'value',
    get: -> if @_value then Math.floor(@_value) else 0
    set: (key, value) -> @_value = value

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