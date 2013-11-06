FK.App.module "ImageTrimmer", (ImageTrimmer, App, Backbone, Marionette, $, _) ->

  Instance = null

  @addFinalizer () ->
    Instance.close()

  @create = (domLocation) ->
    newInstance = new ImageTrimmer.ImageTrimmerController()
    regionManager = new Marionette.RegionManager()
    region = regionManager.addRegion("instance", domLocation)
    region.show new ImageTrimmer.ImageTrimmerLayout
      controller: newInstance

    newInstance.on 'close', () =>
      regionManager.close()

    Instance = newInstance
    return newInstance

  @validImageTypes = () ->
    ['image/jpeg', 'image/png', 'image/gif', 'image/pjpeg', 'image/svg', 'image/tiff']

  class ImageTrimmer.ImageTrimmerController extends Marionette.Controller
 
    initialize: () ->
      @Model = new Backbone.Model()

      @listenTo this, 'new:image', newImage
      @listenTo this, 'change:image:position', catchImagePosition
      @listenTo this, 'change:image:size', catchImageSize

    newImage = (url, source, file) ->
      @Model.set
        url: url
        source: source
        image: file

    catchImagePosition = (position) ->
      @Model.set
        crop_x: position.left
        crop_y: position.top

    catchImageSize = (size) ->
      @Model.set
        width: size.width
        height: size.height

    value: () =>
      image = @Model.toJSON()
      delete image.image if ! image.image
      delete image.url if image.image
      image
