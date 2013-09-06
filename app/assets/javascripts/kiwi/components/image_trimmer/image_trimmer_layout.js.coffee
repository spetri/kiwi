FK.App.module "ImageTrimmer", (ImageTrimmer, App, Backbone, Marionette, $, _) ->

  class this.ImageTrimmerLayout extends Marionette.Layout
    template: FK.Template('image_trimmer_layout')
    regions:
      'imageTrimmerRegion': '#image-trimmer-region'
      'imageChooseRegion': '#image-chooser-region'

    onRender: () ->
      @imageChooseRegion.show new ImageTrimmer.ImageChooseView
        model: this.ViewModel
      @imageTrimmerRegion.show new ImageTrimmer.ImageTrimmerView
        model: this.ViewModel
