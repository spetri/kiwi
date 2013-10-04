FK.App.module "ImageTrimmer", (ImageTrimmer, App, Backbone, Marionette, $, _) ->

  Instances = []

  @create = () ->
    newInstance = new ImageTrimmer.ImageTrimmerController
    Instances.push newInstance
    return newInstance

  @addFinalizer () ->
    _.each Instances, (instance) ->
      instance.close()

  # Layout?
  class ImageTrimmer.ImageTrimmerController extends Marionette.Controller
 
    initialize: () ->
      @View = new ImageTrimmer.ImageTrimmerLayout
        controller: this

      @Model = new Backbone.Model()

      @listenTo this, 'new:image', @newImage
      @listenTo this, 'change:image:position', @catchImagePosition
      @listenTo this, 'change:image:size', @catchImageSize
      @listenTo @View, 'close', () => @triggerMethod 'close'

    view: () ->
      @View

    newImage: (url, source, file) ->
      @Model.set
        url: url
        source: source
        image: file
      
      if source is 'upload'
        @trigger 'new:image:ready', url, source

    catchImagePosition: (position) =>
      @Model.set
        crop_x: position.left
        crop_y: position.top

    catchImageSize: (size) =>
      @Model.set
        width: size.width
        height: size.height

    image: () =>
      image = @Model.toJSON()
      delete image.image if ! image.image
      delete image.url if image.image
      image

    onClose: () ->
      @View.close()
