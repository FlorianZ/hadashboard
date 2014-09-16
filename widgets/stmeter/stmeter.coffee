class Dashing.Stmeter extends Dashing.Widget
  constructor: ->
    super
    @observe 'value', (value) ->
      $(@node).find(".stmeter").val(@queryState).trigger('change')

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
    Stmeter = $(@node).find(".Stmeter")
    Stmeter.attr("data-bgcolor", Stmeter.css("background-color"))
    Stmeter.attr("data-fgcolor", Stmeter.css("color"))
    Stmeter.knob()