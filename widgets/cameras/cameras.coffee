class Dashing.Cameras extends Dashing.ClickableWidget

    endsWith = (str, suffix) -> str.indexOf(suffix, str.length - suffix.length) isnt -1

    # Courtesy @mr-deamon
    resizeImage = ($img, maxWidth, maxHeight, maximize) ->
        width = $img.width()
        height = $img.height()
        delta_x = width-maxWidth
        delta_y = height-maxHeight

        if delta_x <= delta_y
            $img.css("height", maxHeight)
        else
            $img.css("width", maxWidth)

    getImageSize = ($img, done) ->
        loadedHandler = ->
            $img.off 'load', loadedHandler
            done $img.width(), $img.height()

        img = $img[0]
        if !img.complete
            # Wait for the image to load
            $img.on 'load', loadedHandler
        else
            # Image is already loaded.  Call the loadedHandler.
            sleep 0, loadedHandler

    sleep = (timeInMs, fn) -> setTimeout fn, timeInMs

	ready: ->
        container = $(@node).parent()
        @maxWidth = (Dashing.widget_base_dimensions[0] * container.data("sizex")) + Dashing.widget_margins[0] * 2 * (container.data("sizex") - 1)
        @maxHeight = (Dashing.widget_base_dimensions[1] * container.data("sizey"))
        draw this

	onData: (data) -> 
        return if !@maxWidth or !@maxHeight
        draw this

    onClick: (event) ->
        # gridster = $(@node).parent('ul').data('gridster')
        # gridster.resize_widget(1, 2, 2)

 	makeVideo = (url, type) ->
        return $('
            <video preload="auto" autoplay="autoplay" muted="muted" loop="loop" webkit-playsinline>
                <source src="' + url + '" type="' + type + '">
            </video>
        ')

    draw = (self) ->
        $el = $(self.node)

        needResize = false

        # Remove the old image
        $el.find('img').remove()
        $el.find('video').remove()

        # Load the new image
        imageUrl = self.get("image")
        if endsWith imageUrl, ".mp4"
            $img = makeVideo imageUrl, 'video/mp4'
        else if endsWith imageUrl, ".gifv"
            imageUrl = imageUrl[0...-5] + ".mp4"
            $img = makeVideo imageUrl, 'video/mp4'
        else
            # Need to resize images to preserve aspect ration
            needResize = true
            $img = $('<img src="' + self.get("image") + '"/>')
        $el.append $img

        if needResize
            # Resize the image
            getImageSize $img, (width, height) =>
                resizeImage $img, self.maxWidth, self.maxHeight, self.get 'max'
