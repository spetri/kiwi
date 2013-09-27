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

      @listenTo this, 'new:image:url', @imageByUrl

    onClose: () =>
      @View.close()

    view: () ->
      this.View

    imageByUrl: (url) ->
      this.View.openImageTrimmerDialog()
      this.trigger 'new:image:ready', url
