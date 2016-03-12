class Dashing.Clock extends Dashing.Widget

  ready: ->
    setInterval(@startTime, 500)

  startTime: =>
    today = new Date()

    h = today.getHours()
    m = today.getMinutes()
    m = @formatTime(m)

    options = { weekday: 'long', year: 'numeric', month: 'short', day: 'numeric' };
    #options.timeZoneName = 'short';

    @set('time', @formatHours(h) + ":" + m + " " + @formatAmPm(h))
    @set('date', today.toLocaleDateString('en-GB', options)) #today.toLocaleDateString())
    
    
  formatTime: (i) ->
    if i < 10 then "0" + i else i

  formatAmPm: (h) ->
    if h >= 12 then "PM" else "AM"

  formatHours: (h) ->
    if h > 12
      h - 12
    else if h == 0
      12
    else
      h