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

    startImage: (width, height, trim_width, trim_height) ->

      wToH = height / width

      if wToH < @get('ratio')
        minWidth = trim_height / wToH
      else
        minWidth = trim_width

      @set
        original_width: width
        original_height: height
        wToH: wToH
        min_width: minWidth

    undersized: ->
      @get('width') < @get('min_width')

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

    adjustedWidth: (factor) =>
      @get('min_width') + (@get('width') - @get('min_width')) * factor

    ratioToOriginalHeight: ->
      @get('original_height') / @get('height')

    ratioToOriginalWidth: ->
      @get('original_width') / @get('width')


    image: () ->
      image = @toJSON()
      delete image.image if ! image.image
      delete image.url if image.image
      image
