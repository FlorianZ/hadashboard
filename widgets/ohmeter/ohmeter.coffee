class Dashing.Ohmeter extends Dashing.Widget
  constructor: ->
    super
    @queryState()
    @observe 'value', (value) ->
      $(@node).find(".ohmeter").val(value).trigger('change')
    
  @accessor 'value', Dashing.AnimatedValue    

  queryState: ->
    $.get '/openhab/dispatch',
      widgetId: @get('id'),
      deviceId: @get('device'),
      deviceType: 'power'
      (data) =>
        json = JSON.parse data
        @set 'value', json.state

  ready: ->
    ohmeter = $(@node).find(".ohmeter")
    ohmeter.attr("data-bgcolor", ohmeter.css("background-color"))
    ohmeter.attr("data-fgcolor", ohmeter.css("color"))
    ohmeter.knob()
  
  onData: (data) ->