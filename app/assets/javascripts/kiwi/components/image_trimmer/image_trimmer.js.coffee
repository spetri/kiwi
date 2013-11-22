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

    image: () ->
      image = @toJSON()
      delete image.image if ! image.image
      delete image.url if image.image
      image
