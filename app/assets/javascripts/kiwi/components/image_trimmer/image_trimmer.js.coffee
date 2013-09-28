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
      @listenTo @View, 'close', () => @triggerMethod 'close'

    view: () ->
      @View

    imageByUrl: (url) ->
      @View.openImageTrimmerDialog()
      @trigger 'new:image:ready', url

    onClose: () ->
      @View.close()
