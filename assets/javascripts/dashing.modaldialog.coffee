class Dashing.ModalDialog

  constructor: (node) ->
    @dialogNode = node
    @overlayNode = $('.md-overlay')
    $('#md-location').append @dialogNode

  show: ->
    @dialogNode.addClass('md-show')
    @dialogNode.find('.md-close').on 'click', (evt) => @hide()
    @overlayNode.addClass('md-show')
    @overlayNode.on 'click', (evt) -> evt.stopPropagation()

  hide: ->
    @dialogNode.removeClass('md-show')
    @dialogNode.find('.md-close').off 'click'
    @overlayNode.removeClass('md-show')
    @overlayNode.off 'click'
