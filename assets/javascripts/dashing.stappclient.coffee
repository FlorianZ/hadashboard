#= require dashing
#= require dashing.modaldialog

class Dashing.STAppClient

  api_version: 'v1'

  queues: {}
  queue_timeout: 500

  request: (verb, path, params, callback = null) ->
    params.path = @api_version + '/' + path
    verb = verb.toUpperCase()
    $.ajax
      type: verb
      url: '/smartthings/dispatch'
      data: if verb == 'POST' then JSON.stringify params else params
      contentType: 'application/json'
    .done callback

  flush: (verb, path, params) ->
    @request verb, path, params,
      (data) =>
        json = JSON.parse data
        if not json.error?
          for widget_id, values of json
            if Dashing.widgets[widget_id]?
              Dashing.widgets[widget_id].receiveData values

  queue: (verb, path, params) ->
    if not @queues[path]
      @queues[path] = { timer: null, params: {} }
    else
      clearTimeout @queues[path].timer

    for k, v of params
      @queues[path].params[k] = v

    @queues[path].timer =
      setTimeout (=> @flush verb, path, @queues[path].params),
      @queue_timeout

  getDevices: () ->
    response = {}
    @request 'get', 'info/devices', {}, (data) => response = JSON.parse data
    return response

Dashing.stAppClient = new Dashing.STAppClient

$(document).ready ->
  Dashing.stAppClient.request 'get', 'info/devices', {},
    (data) =>
        if not data or Object.keys(JSON.parse(data)).length == 0
          dialogNode = $('#no-devices')
          dialog = new Dashing.ModalDialog $(dialogNode)
          $(dialogNode).find('.md-confirm').on 'click', (evt) ->
            window.location = 'smartthings/authorize'
            dialog.hide()
          dialog.show()