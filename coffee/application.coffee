init = ->
  window.dropper   = new ImageDropper($('.drop-target'))
  window.generator = new Generator(395, 395, 92)

  dropper.onImageDropped = (image) ->
    generator.backgroundImage(image)

  ko.applyBindings(generator)

class Generator
  draw = (width, height, callback) ->
    canvas = document.createElement('canvas')
    canvas.width = width
    canvas.height = height

    callback(canvas.getContext('2d'))

    output = new Image
    output.width = width
    output.height = height
    output.src = canvas.toDataURL()
    output

  constructor: (jamvatarWidth, jamvatarHeight, jamvatarOffsetY) ->
    @backgroundImage = ko.observable(null)

    @jamvatarImage = ko.computed =>
      backgroundImage = @backgroundImage()
      return null unless backgroundImage?

      console.log "drawing jamvatarImage"

      draw jamvatarWidth, jamvatarHeight, (ctx) =>
        ctx.drawImage(backgroundImage, jamvatarWidth/2 - backgroundImage.width/2, -jamvatarOffsetY)

    @wrapperCSS = ko.computed =>
      css = "box-sizing: border-box; padding-top: #{jamvatarOffsetY}px;"

      if image = @backgroundImage()
        css += "background-image: url(#{image.src}); background-position: top center;"

      css

    @jamvatarWrapperCSS = -> "width: #{jamvatarWidth}px; height: #{jamvatarHeight}px"

    @jamvatarCSS = ko.computed =>
      css = "width: #{jamvatarWidth}px; height: #{jamvatarHeight}px;"

      if image = @jamvatarImage()
        css += "background-image: url(#{image.src});"

      css

    @showControls = ko.computed => @backgroundImage()?

  downloadBackground: -> window.open(@backgroundImage().src)
  downloadJamvatar:   -> window.open(@jamvatarImage().src)

class ImageDropper
  constructor: (target) ->
    target = $(target)

    target    
      .bind 'dragover', (event) ->
        event.stopPropagation()
        event.preventDefault()
        target.addClass('dragover')

      .bind 'dragout', (event) ->
        event.stopPropagation()
        event.preventDefault()
        target.removeClass('dragover')

      .bind 'drop', (event) =>
        event.stopPropagation()
        event.preventDefault()
        target.removeClass('dragover')
        @getImage(event.originalEvent.dataTransfer.files)

  getImage: (files) ->
    reader = new FileReader
    
    reader.onload = (event) =>
      img = new Image
      img.src = event.target.result
      img.onload = =>
        @onImageDropped(img) if @onImageDropped?

    reader.readAsDataURL(files[0])

init()