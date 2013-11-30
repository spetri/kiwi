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

    startImage: (width, height, trim_width, trim_height) ->
      wToH = height / width

      if wToH < @get('ratio')
        minWidth = trim_height / wToH
      else
        minWidth = trim_width

      @set
        width: width
        height: height
        original_width: width
        original_height: height
        wToH: wToH
        min_width: minWidth
        trim_width: trim_width
        trim_height: trim_height

    startTrim: (borderLeft, borderTop) =>
      @set
        border_left: borderLeft
        border_top: borderTop
    
    started: ->
      @get('original_width') > 0

    undersized: ->
      @get('width') < @get('min_width')

    sizable: ->
      @started() and not @undersized()

    movable: ->
      @started() and not @undersized()

    setImagePosition: (position) ->
      @set
        crop_x: position.left
        crop_y: position.top

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

    adjustedWidth: (factor) =>
      @get('min_width') + (@get('original_width') - @get('min_width')) * factor

    ratioToOriginalHeight: ->
      @get('original_height') / @get('height')

    ratioToOriginalWidth: ->
      @get('original_width') / @get('width')


    image: () ->
      image = @toJSON()
      delete image.image if ! image.image
      delete image.url if image.image
      image
