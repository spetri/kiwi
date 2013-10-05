describe 'Image Trimmer', () ->

  beforeEach () ->
    FK.App.ImageTrimmer.start()
    @imageTrimmer = FK.App.ImageTrimmer.create()
    $('body').append @imageTrimmer.View.render().el

  afterEach () ->
    FK.App.ImageTrimmer.stop()

  describe 'Memory management', () ->

    it 'should close all instances of the image trimmer when the module stops', () ->
      FK.App.ImageTrimmer.stop()
      expect($('body #image-trimmer-region').length).toBe(0)
