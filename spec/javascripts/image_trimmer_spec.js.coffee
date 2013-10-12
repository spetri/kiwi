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

  describe 'Image loading', () ->

    it 'should be able to show an image in the trimmer from a URL', () ->
      spy = jasmine.createSpy()
      @imageTrimmer.on 'new:image:ready', spy
      runs () ->
        imageUrl = '/images/stubs/averageSize.jpg'
        @imageTrimmer.trigger 'new:image', imageUrl, 'remote'
      
      waitsFor () ->
        spy.callCount > 0

      runs () ->
        expect($('img').width()).toBeGreaterThan(0)



