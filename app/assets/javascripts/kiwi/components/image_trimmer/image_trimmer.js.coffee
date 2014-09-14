FK.App.module "ImageTrimmer", (ImageTrimmer, App, Backbone, Marionette, $, _) ->

  @Instance = null

  @addFinalizer () ->
    @trimmer().close()

  @create = (domLocation, model) ->
    @Instance = null
    regionManager = new Marionette.RegionManager()
    region = regionManager.addRegion("instance", domLocation)

    @trimmer().on 'close', () =>
      regionManager.close()

    layout = new ImageTrimmer.ImageTrimmerLayout
      model: @trimmer().model
      controller: @trimmer()

    region.show layout
    @startup(model)

    return @trimmer()


  # singleton factory:
  @trimmer = () =>
    if @Instance is null
      @Instance = new ImageTrimmer.ImageTrimmerController()
    return @Instance

  @startup = (model, trimmer) =>
    if model.get('originalUrl')
      @reloadImage model.get('originalUrl')
      @setImageSize model, model.get('width')
      @trimmer().setPosition model.get('crop_x'), model.get('crop_y')

  @reloadImage = (url) =>
    @trimmer().newImage url, 'reload'

  @setImageUrl = (model, url) =>
    @trimmer().newImage url, 'remote'

  @setImageSize = (model, width) =>
    @trimmer().setWidth width

  @validImageTypes = () ->
    ['image/jpeg', 'image/png', 'image/pjpeg']

  class ImageTrimmer.ImageTrimmerController extends Marionette.Controller

    initialize: () ->
      @model = new ImageTrimmer.ImageCalculator()

      @listenTo @model, 'new:image:ready', () => @trigger 'new:image:ready'
      @listenTo @model, 'new:image:ready', () => @imageReady.resolve()
      @imageReady = $.Deferred()

    newImage: (url, source, file) ->
      @imageReady = $.Deferred()

      if source is 'remote'
        @model.newRemoteImage url
      else if source is 'uploaded'
        @model.newUploadedImage url, file
      else if source is 'reload'
        @model.newReloadedImage url

    setWidth: (width) ->
      @imageReady.then( () =>
        @model.setSizeByWidth(width)
      )

    setPosition: (x, y) ->
      @imageReady.then( () =>
        @model.setPosition(x, y)
      )

    imageIsReady: ->
      @imageReady.state() is 'resolved'

    value: () =>
      @model.image()

  class ImageTrimmer.ImageCalculator extends Backbone.Model
    defaults: () =>
      height: 0
      width: 0
      min_width: 0
      crop_x: 0
      crop_y: 0
      wToH: 0
      ratio: 0.75
      trim_height: 0
      trim_width: 0
      border_left: 0
      border_top: 0
      source: 'none'

    initialize: ->
      @listenTo @, 'change:width', @updateHeightByRatio
      @listenTo @, 'change:slider_factor', @updateWidthBySliderFactor

    updateHeightByRatio: ->
      @set('height', @get('width') * @get('wToH'))

    updateWidthBySliderFactor: ->
      @set('width', @adjustedWidth())

    newUploadedImage: (file, url) ->
      @reset()
      @set
        file: file
        url: url
        source: 'upload'

    newRemoteImage: (url) ->
      @reset()
      @set
        url: url
        source: 'remote'

    newReloadedImage: (url) ->
      @reset()
      @set
        url: url
        source: 'reload'

    reset: () ->
      @clear()
      this.set this.defaults()

    startImage: (width, height, trimWidth, trimHeight, borderLeft, borderTop, borderBottom) ->
      wToH = height / width

      if wToH < @get('ratio')
        minWidth = trimHeight / wToH
      else
        minWidth = trimWidth

      @set
        width: width
        height: height
        max_width: width
        max_height: height
        wToH: wToH
        min_width: minWidth
        trim_width: trimWidth
        trim_height: trimHeight
        border_left: borderLeft
        border_top: borderTop
        border_bottom: borderBottom
        slider_factor: 0

      @centerImage()

      @trigger('new:image:ready')

    resetSlider: ->
      @set 'slider_factor', 0

    started: ->
      @get('source') != 'none'

    undersized: ->
      @get('max_width') < @get('min_width')

    sizable: ->
      @started() and not @undersized()

    movable: ->
      @started() and not @undersized()

    trimFullWidth: ->
      @get('border_left') * 2 + @get('trim_width')

    trimFullHeight: ->
      @get('border_top') + @get('border_bottom') + @get('trim_height')

    startMoving: (fromX, fromY) ->
      return if not @movable()

      @set('moving_start_offset',
        left: fromX
        top: fromY
      )

      @saveImageCoords()

    startSizing: ->
      return false if not @sizable()
      @saveImageCoords()

    saveImageCoords: () ->
      @set('image_start_offset',
        left: @get('crop_x')
        top: @get('crop_y')
      )

      @set('image_start_size',
        width: @get('width')
        height: @get('height')
      )

    move: (byX, byY) ->
      return if not @moving()
      left = @get('image_start_offset').left + byX - @get('moving_start_offset').left
      top = @get('image_start_offset').top + byY - @get('moving_start_offset').top
      @positionImage(left, top)

    moving: () ->
      @has('moving_start_offset')

    stopMoving: () ->
      @unset 'moving_start_offset'
      @unset 'image_start_offset'

    size: (factor) ->
      @set 'slider_factor', factor

    centerImage: ->
      overflowedRight = @get('width') - @trimFullWidth()
      overflowedBottom = @get('height') - @trimFullHeight()
      @positionImage Math.floor(-overflowedRight / 2), Math.floor(-overflowedBottom / 2)

    positionImage: (x, y) ->
      @set 'crop_x', @limitImageHorizontalPosition(@get('width'), x)
      @set 'crop_y', @limitImageVerticalPosition(@get('width'), y)

    refocusImage: =>
      newLeft = @get('image_start_offset').left + (@get('image_start_size').width - @get('width')) / 2
      newTop = @get('image_start_offset').top + (@get('image_start_size').height - @get('height')) / 2

      outFlowWidth = (@get('trim_width') + @get('border_left')) - (@get('width') + newLeft)
      outFlowHeight = (@get('trim_height') + @get('border_top')) - (@get('height') + newTop)

      outFlowWidth = 0 if outFlowWidth < 0
      outFlowHeight = 0 if outFlowHeight < 0

      @positionImage Math.floor(newLeft + outFlowWidth), Math.floor(newTop + outFlowHeight)

    limitImageHorizontalPosition: (width, x) =>
      return @get('border_left') if x > @get('border_left')
      return -width + @get('border_left') + @get('trim_width') if x + width < @get('trim_width') + @get('border_left')
      x

    limitImageVerticalPosition: (width, y) =>
      height = Math.ceil width * @get('wToH')
      return @get('border_top') if y > @get('border_top')
      return -height + @get('border_top') + @get('trim_height') if y + height < @get('trim_height') + @get('border_top')
      y

    adjustedWidth: () =>
      @get('min_width') + (@get('max_width') - @get('min_width')) * @get('slider_factor')

    ratioToOriginalHeight: ->
      @get('max_height') / @get('height')

    ratioToOriginalWidth: ->
      @get('max_width') / @get('width')

    setSizeByWidth: (width) ->
      width = @get('min_width') if width < @get('min_width')
      width = @get('max_width') if width > @get('max_width')
      modelWidth = @get('max_width') * @get('trim_width') / width
      @size (modelWidth - @get('min_width'))/(@get('max_width') - @get('min_width'))

    setPosition: (x, y) ->
      crop_x = -x / @ratioToOriginalWidth() + @get('border_left')
      crop_y = -y / @ratioToOriginalHeight() + @get('border_top')
      @positionImage(crop_x, crop_y)

    image: () ->
      image =
        crop_x: - (@get('crop_x') - @get('border_left')) * @ratioToOriginalWidth()
        crop_y: - (@get('crop_y') - @get('border_top')) * @ratioToOriginalHeight()
        width: @get('trim_width') * @ratioToOriginalWidth()
        height: @get('trim_height') * @ratioToOriginalHeight()

      image.image = @get('file') if @get('source') is 'upload'
      image.url = @get('url') if @get('source') is 'remote'

      image
