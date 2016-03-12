class Dashing.Ohweathertoday extends Dashing.Widget
  constructor: ->
    super
    @_icons =
      chanceflurries: '&#xe036',
      chancerain: '&#xe009',
      chancesleet: '&#xe003',
      chancesnow: '&#xe036',
      chancetstorms: '&#xe025',
      clear: '&#xe028',
      cloudy: '&#xe000',
      flurries: '&#xe036',
      fog: '&#xe01b',
      hazy: '&#xe01b',
      mostlycloudy: '&#xe001',
      mostlysunny: '&#xe001',
      partlycloudy: '&#xe001',
      partlysunny: '&#xe001',
      sleet: '&#xe003',
      rain: '&#xe009',
      snow: '&#xe036',
      sunny: '&#xe028',
      tstorms: '&#xe025'

  @accessor 'climacon', ->
    new Batman.TerminalAccessible (attr) =>
      @_icons[attr]

  @accessor 'now_temp',
    get: -> if @_temp then Math.floor(@_temp) else 0
    set: (key, value) -> @_temp = value

  ready: ->

  onData: (data) ->
