FK.App.module "ImageTrimmer", (ImageTrimmer, App, Backbone, Marionette, $, _) ->
  
  class ImageTrimmer.ImageTrimmerViewModel extends Backbone.Model
    defaults:
      type: 'url'
      source: ''
