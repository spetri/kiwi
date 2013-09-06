FK.App.module "ImageTrimmer", (ImageTrimmer, App, Backbone, Marionette, $, _) ->

  this.startsWithParent = false
 
  this.addInitializer () ->
    this.ViewModel = new this.ImageTrimmerViewModel()
    this.View = new this.ImageTrimmerLayout()


  this.addFinalizer () ->
    this.View.close()
    this.ViewModel.stopListening()
    this.ViewModel.off()

    this.View = null
    this.ViewModel = null

  this.here = () ->
    this.start()
    this.View

  this.loadFromUrl = (url) ->
    url
