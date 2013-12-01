FK.App.module "ImageTrimmer", (ImageTrimmer, App, Backbone, Marionette, $, _) ->

  Instance = null

  @addFinalizer () ->
    Instance.close()

  @create = (domLocation) ->

    newInstance = new ImageTrimmer.ImageTrimmerController()

    regionManager = new Marionette.RegionManager()
    region = regionManager.addRegion("instance", domLocation)

    newInstance.on 'close', () =>
      regionManager.close()

    layout = new ImageTrimmer.ImageTrimmerLayout
      model: newInstance.model
      controller: newInstance

    region.show layout

    Instance = newInstance
    return newInstance

  @validImageTypes = () ->
    ['image/jpeg', 'image/png', 'image/gif', 'image/pjpeg', 'image/svg', 'image/tiff']

  class ImageTrimmer.ImageTrimmerController extends Marionette.Controller
 
    initialize: () ->
      @model = new ImageTrimmer.ImageCalculator()

      @listenTo this, 'new:image', newImage

    newImage = (url, source, file) ->
      @model.newImage(url, source, file)

    value: () =>
      @model.image()

  class ImageTrimmer.ImageCalculator extends Backbone.Model
    defaults:
      original_height: 0
      original_width: 0
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

    initialize: ->
      @listenTo @, 'change:width', @updateHeightByRatio
      @listenTo @, 'change:slider_factor', @updateWidthBySliderFactor

    updateHeightByRatio: ->
      @set('height', @get('width') * @get('wToH'))

    updateWidthBySliderFactor: ->
      @set('width', @adjustedWidth())

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

    resetSlider: ->
      @set 'slider_factor', 0
    
    started: ->
      @get('max_width') > 0

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

    centerImage: ->
      overflowedRight = @get('width') - @trimFullWidth()
      overflowedBottom = @get('height') - @trimFullHeight()
      @positionImage Math.floor(-overflowedRight / 2), Math.floor(-overflowedBottom / 2)

    setImagePosition: (position) ->
      @set
        crop_x: position.left
        crop_y: position.top

    positionImage: (x, y) ->
      @set('crop_x', x) if not @imageHorizontalOutOfBounds(@get('width'), x)
      @set('crop_y', y) if not @imageVerticalOutOfBounds(@get('width'), y)

    setImageSize: (size) ->
      @set
        width: size.width
        height: size.height

    newImage: (url, source, file) ->
      @set
        url: url
        source: source
        image: file

    imageHorizontalOutOfBounds: (width, x) =>
      x = x - @get('border_left')
      x > 0 || x + width < @get('trim_width')

    imageVerticalOutOfBounds: (width, y) =>
      y = y - @get('border_top')
      height = Math.ceil width * @get('wToH')
      y > 0 || y + height < @get('trim_height')

    adjustedWidth: () =>
      @get('min_width') + (@get('max_width') - @get('min_width')) * @get('slider_factor')

    ratioToOriginalHeight: ->
      @get('max_height') / @get('height')

    ratioToOriginalWidth: ->
      @get('max_width') / @get('width')


    image: () ->
      image = @toJSON()
      delete image.image if ! image.image
      delete image.url if image.image
      image
