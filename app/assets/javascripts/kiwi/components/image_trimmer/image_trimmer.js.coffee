FK.App.module "ImageTrimmer", (ImageTrimmer, App, Backbone, Marionette, $, _) ->
 
  ImageTrimmer.addInitializer () ->
    ImageTrimmer.View = new ImageTrimmer.ImageTrimmerView()
    ImageTrimmer.ViewModel = new ImageTrimmer.ImageTrimmerViewModel()
 
  ImageTrimmer.loadFromUrl = (url) ->
    url
