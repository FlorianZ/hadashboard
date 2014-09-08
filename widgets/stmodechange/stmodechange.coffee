class Dashing.Stmodechange extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'icon',
    get: -> @['icon'] ? 'tag'
    set: Batman.Property.defaultAccessor.set

  @accessor 'mode',
    get: -> @_mode ? 'Unknown'
    set: (key, value) -> @_mode = value

  @accessor 'countdown',
    get: -> @_countdown ? 0
    set: (key, value) -> @_countdown = value

  @accessor 'timer',
    get: -> @_timer ? 0
    set: (key, value) -> @_timer = value

  showTimer: ->
    $(@node).find('.icon').hide()
    $(@node).find('.timer').show()

  showIcon: ->
    $(@node).find('.timer').hide()
    $(@node).find('.icon').show()

  isModeSet: ->
    @get('mode') == @get('changemode')

  updateBackgroundColor: ->
    if @isModeSet()
      $(@node).css 'background-color', '#42C873'
    else
      $(@node).css 'background-color', '#888888'

  queryState: ->
    $.get '/smartthings/dispatch',
      widgetId: @get('id'),
      deviceType: 'mode'
      (data) =>
        json = JSON.parse data
        @set 'mode', json.mode
        @updateBackgroundColor()

  postModeState: ->
    oldMode = @get 'mode'
    @set 'mode', @get('changemode')
    @updateBackgroundColor()
    $.post '/smartthings/dispatch',
      deviceType: 'mode',
      mode: @get('changemode'),
      (data) =>
        json = JSON.parse data
        if json.error != 0
          @set 'mode', oldModeM
          @updateBackgroundColor()

  postPhraseState: ->
    $.post '/smartthings/dispatch',
      deviceType: 'phrase',
      phrase: @get('phrase')
      (data) =>
        @queryState()

  ready: ->
    @showIcon()

  onData: (data) ->
    @updateBackgroundColor()

  changeModeDelayed: =>
    if @get('timer') <= 0
      @showIcon()
      if @get('phrase')
        @postPhraseState()
      else
        @postModeState()
      @_timeout = null
    else
      @showTimer()
      @set 'timer', @get('timer') - 1
      @_timeout = setTimeout(@changeModeDelayed, 1000)

  onClick: (node, event) ->
    if not @_timeout and not @isModeSet()
      @set 'timer', @get('countdown')
      @changeModeDelayed()
