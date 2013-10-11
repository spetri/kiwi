describe 'Image Trimmer', () ->

  beforeEach () ->
    FK.App.ImageTrimmer.start()
    $('body').append $('<div id="testbed"></div>')
    @imageTrimmer = FK.App.ImageTrimmer.create("#testbed")

  afterEach () ->
    FK.App.ImageTrimmer.stop()

  describe 'Memory management', () ->

    it 'should close all instances of the image trimmer when the module stops', () ->
      FK.App.ImageTrimmer.stop()
      expect($('body #image-trimmer-region').length).toBe(0)
