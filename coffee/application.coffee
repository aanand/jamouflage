init = ->
  window.dropper   = new ImageDropper($('.drop-target'))
  window.generator = new Generator(395, 395, 91)

  dropper.onImageDropped = (image) ->
    generator.image(image)

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
    @image = ko.observable(null)

    @scaleInput   = ko.observable("100")
    @yOffsetInput = ko.observable("0")

    @backgroundImage = ko.computed =>
      image = @image()
      return null unless image?

      console.log "drawing backgroundImage"

      width  = image.width * @scale()
      height = image.height * @scale()

      draw width, height, (ctx) =>
        ctx.drawImage(image, 0, @yOffset(), width, height)

    @jamvatarImage = ko.computed =>
      backgroundImage = @backgroundImage()
      return null unless backgroundImage?

      console.log "drawing jamvatarImage"

      draw jamvatarWidth, jamvatarHeight, (ctx) =>
        x = jamvatarWidth/2 - backgroundImage.width/2
        y = -jamvatarOffsetY + @yOffset()

        ctx.drawImage(@image(), x, y, backgroundImage.width, backgroundImage.height)

    @wrapperCSS = ko.computed =>
      css = "padding-top: #{jamvatarOffsetY}px; background-color: pink;"

      if image = @backgroundImage()
        css += "background-image: url(#{image.src}); background-position: top center;"

      css

    @jamvatarWrapperCSS = -> "width: #{jamvatarWidth}px; height: #{jamvatarHeight}px"

    @jamvatarCSS = ko.computed =>
      css = "width: #{jamvatarWidth}px; height: #{jamvatarHeight}px; background-color: yellow;"

      if image = @jamvatarImage()
        css += "background-image: url(#{image.src});"

      css

    @showForm = ko.computed => @image()?

  scale: -> (Number(@scaleInput()) || 100)/100
  yOffset: -> Number(@yOffsetInput()) || 0

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