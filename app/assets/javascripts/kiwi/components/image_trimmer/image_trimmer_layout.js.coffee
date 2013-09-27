FK.App.module "ImageTrimmer", (ImageTrimmer, App, Backbone, Marionette, $, _) ->

  class this.ImageTrimmerLayout extends Marionette.Layout
    template: FK.Template('image_trimmer_layout')
    regions:
      'imageTrimmerRegion': '#image-trimmer-region'
      'imageChooseRegion': '#image-chooser-region'

    initialize: (options) ->
      @controller = options.controller

    openImageTrimmerDialog: () ->
      @imageTrimmerRegion.show new ImageTrimmer.ImageTrimmerView
        controller: @controller

    onRender: () ->
      @imageChooseRegion.show new ImageTrimmer.ImageChooseView
        controller: @controller
