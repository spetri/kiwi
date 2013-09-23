FK.App.module "ImageTrimmer", (ImageTrimmer, App, Backbone, Marionette, $, _) ->

  this.startsWithParent = false
 
  this.addInitializer () ->
    this.ViewModel = new this.ImageTrimmerViewModel()
    this.View = new this.ImageTrimmerLayout()

    this.listenTo ImageTrimmer, 'new:image:url', this.imageByUrl

  this.addFinalizer () ->
    this.View.close()
    this.ViewModel.stopListening()
    this.ViewModel.off()

    this.View = null
    this.ViewModel = null

    this.stopListening()

  this.here = () ->
    this.start()
    this.View

  this.imageByUrl = (url) ->
    this.View.openImageTrimmerDialog()
    this.trigger 'new:image:ready', url
