describe 'Image Trimmer', () ->

  beforeEach () ->
    FK.App.ImageTrimmer.start()
    $('body').append $('<div id="testbed"></div>')
    @imageTrimmer = FK.App.ImageTrimmer.create("#testbed", new FK.Models.Event)

  afterEach () ->
    $('body #testbed').remove()
    FK.App.ImageTrimmer.stop()

  describe 'Memory management', () ->

    it 'should close all instances of the image trimmer when the module stops', () ->
      FK.App.ImageTrimmer.stop()
      expect($('body #image-trimmer-region').length).toBe(0)

  describe 'Image setting', () ->
    it 'should be able to load an image', () ->
      imageUrl = '/images/stubs/averageSize.jpg'
      @imageTrimmer.newImage imageUrl, 'remote'
      expect(@imageTrimmer.value().url).toBe(imageUrl)

    it 'should be able to set the images width', () ->
      spy = jasmine.createSpy()
      @imageTrimmer.on 'new:image:ready', spy
      runs () ->
        imageUrl = '/images/stubs/averageSize.jpg'
        @imageTrimmer.newImage imageUrl, 'remote'

      waitsFor () ->
        spy.callCount > 0

      runs () ->
        @imageTrimmer.setWidth 500
        expect(Math.ceil(@imageTrimmer.value().width)).toBe(500)

    it 'should be able to set the images position', () ->
      spy = jasmine.createSpy()
      @imageTrimmer.on 'new:image:ready', spy
      runs () ->
        imageUrl = '/images/stubs/averageSize.jpg'
        @imageTrimmer.newImage imageUrl, 'remote'
        @imageTrimmer.setWidth 500
        @imageTrimmer.setPosition 200, 300

      waitsFor () ->
        spy.callCount > 0

      runs () ->
        expect(Math.ceil(@imageTrimmer.value().crop_x)).toBe(200)
        expect(Math.ceil(@imageTrimmer.value().crop_y)).toBe(300)

    it 'should be able to set the images width before the image is ready', () ->
      spy = jasmine.createSpy()
      @imageTrimmer.on 'new:image:ready', spy
      runs () ->
        imageUrl = '/images/stubs/averageSize.jpg'
        @imageTrimmer.newImage imageUrl, 'remote'
        @imageTrimmer.setWidth 400
        @imageTrimmer.setPosition 200, 300

      waitsFor () ->
        spy.callCount > 0

      runs () ->
        expect(Math.ceil(@imageTrimmer.value().width)).toBe(400)
        expect(Math.ceil(@imageTrimmer.value().crop_x)).toBe(200)
        expect(Math.ceil(@imageTrimmer.value().crop_y)).toBe(300)


    it 'should be able to set the coordinates of an image', () ->
      spy = jasmine.createSpy()
      @imageTrimmer.on 'new:image:ready', spy
      runs () ->
        imageUrl = '/images/stubs/averageSize.jpg'
        @imageTrimmer.newImage imageUrl, 'remote'

      waitsFor () ->
        spy.callCount > 0

      runs () ->
        @imageTrimmer.setWidth 500
        @imageTrimmer.setPosition 100, 50
        expect(@imageTrimmer.value().crop_x).toBe(100)
        expect(@imageTrimmer.value().crop_y).toBe(50)

  describe 'Validation', () ->
    beforeEach () ->
      imageUrl = '/images/stubs/averageSize.jpg'
      @imageTrimmer.newImage imageUrl, 'remote'

    it 'should be able to handle when a width is set to be too small', () ->
      waitsFor () =>
        @imageTrimmer.imageIsReady()

      runs () ->
        @imageTrimmer.setWidth 100
        expect(Math.ceil(@imageTrimmer.value().width)).toBe @imageTrimmer.model.get('min_width')

    it 'should be able to handle when a width is set to be too large', () ->
      waitsFor () =>
        @imageTrimmer.imageIsReady()

      runs () ->
        @imageTrimmer.setWidth 5000
        expect(Math.ceil(@imageTrimmer.value().width)).toBe @imageTrimmer.model.get('max_width')

    it 'should be able to handle when the x position is set to be too far right', () ->
      waitsFor () =>
        @imageTrimmer.imageIsReady()

      runs () ->
        @imageTrimmer.setWidth 500
        @imageTrimmer.setPosition 20, 0
        @imageTrimmer.setPosition -1, 0
        expect(@imageTrimmer.value().crop_x).toBe(0)

    it 'should be able to handle when the x position is set to be too far left', () ->
      waitsFor () =>
        @imageTrimmer.imageIsReady()

      runs () ->
        @imageTrimmer.setWidth 500
        @imageTrimmer.setPosition 20, 0
        @imageTrimmer.setPosition 525, 0
        expect(@imageTrimmer.value().crop_x).toBe(524)

    it 'should be able to handle when the y position is set to be too far down', () ->
      waitsFor () =>
        @imageTrimmer.imageIsReady()

      runs () ->
        @imageTrimmer.setWidth 500
        @imageTrimmer.setPosition 0, 50
        @imageTrimmer.setPosition 0, -1
        expect(@imageTrimmer.value().crop_y).toBe(0)

    it 'should be able to handle when the y position is set to be too far up', () ->
     waitsFor () =>
        @imageTrimmer.imageIsReady()

      runs () ->
        @imageTrimmer.setWidth 500
        @imageTrimmer.setPosition 0, 50
        @imageTrimmer.setPosition 0, 395
        expect(Math.floor(@imageTrimmer.value().crop_y)).toBe(394)
 

  describe 'Image loading', () ->

    it 'should be able to show an image in the trimmer from a URL', () ->
      spy = jasmine.createSpy()
      @imageTrimmer.on 'new:image:ready', spy
      runs () ->
        imageUrl = '/images/stubs/averageSize.jpg'
        @imageTrimmer.newImage imageUrl, 'remote'

      waitsFor () ->
        spy.callCount > 0

      runs () ->
        expect($('img').width()).toBeGreaterThan(0)

    it 'should be able to fit a 4x3 image squarely in the image trimmer view on load', () ->
      spy = jasmine.createSpy()
      @imageTrimmer.on 'new:image:ready', spy
      runs () ->
        imageUrl = '/images/stubs/averageSize.jpg'
        @imageTrimmer.newImage imageUrl, 'remote'

      waitsFor () ->
        spy.callCount > 0

      runs () ->
        trimWidth = $('.image-trim').width()
        trimHeight = $('.image-trim').height()
        leftOffset = $('.image-trim').offset().left + parseInt($('.image-trim').css('border-left-width'))
        topOffset = $('.image-trim').offset().top + parseInt($('.image-trim').css('border-top-width'))

        expect($('img').width()).toBe(trimWidth)
        expect($('img').height()).toBe(trimHeight)
        expect($('img').offset().left).toBe(leftOffset)
        expect($('img').offset().top).toBe(topOffset)

    it 'should be able to fit an image that is not 4x3 and having a greater height', () ->
      spy = jasmine.createSpy()
      @imageTrimmer.on 'new:image:ready', spy
      runs () ->
        imageUrl = '/images/stubs/averageSizeRotated.jpg'
        @imageTrimmer.newImage imageUrl, 'remote'

      waitsFor () ->
        spy.callCount > 0

      runs () ->
        trimWidth = $('.image-trim').width()
        leftOffset = $('.image-trim').offset().left + parseInt($('.image-trim').css('border-left-width'))
        expect($('img').width()).toBe(trimWidth)
        expect($('img').offset().left).toBe(leftOffset)

    it 'should be able to fit an image that is not 4x3 and having a greater width', () ->
      spy = jasmine.createSpy()
      @imageTrimmer.on 'new:image:ready', spy
      runs () ->
        imageUrl = '/images/stubs/longImage.jpg'
        @imageTrimmer.newImage imageUrl, 'remote'

      waitsFor () ->
        spy.callCount > 0

      runs () ->
        trimHeight = $('.image-trim').height()
        topOffset = $('.image-trim').offset().top + parseInt($('.image-trim').css('border-top-width'))

        expect($('img').height()).toBe(trimHeight)
        expect($('img').offset().top).toBe(topOffset)

    it 'should not hang on to its state between images', () ->
     runs () ->
        imageUrl = '/images/stubs/averageSize.jpg'
        @imageTrimmer.newImage imageUrl, 'remote'

      waitsFor () ->
        @imageTrimmer.imageIsReady()

      runs () ->
        @imageTrimmer.setWidth 600
        @imageTrimmer.setPosition 200, 100

        @imageTrimmer.newImage '/images/stubs/longImage.jpg', 'remote'

      waitsFor () ->
        @imageTrimmer.imageIsReady()

      runs () ->
        expect(Math.ceil(@imageTrimmer.value().height)).toBe(619)
        expect(Math.ceil(@imageTrimmer.value().crop_x)).toBe(489)
        expect(@imageTrimmer.value().crop_y).toBe(0)
