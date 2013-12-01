FK.App.module "ImageTrimmer", (ImageTrimmer, App, Backbone, Marionette, $, _) ->

  class ImageTrimmer.ImageTrimmerView extends Marionette.ItemView
    template: FK.Template('image_trimmer')
    className: 'image-trimmer-dialog'
 
    initialize: (options) ->
      @controller = options.controller
      @listenTo @controller, 'new:image:error', @clearImage
 
    events:
      'mousedown .slider': 'startSliding'
      'mousedown .image-container': 'startMoving'
      'click .close-box': 'close'
      'click .cancel-button': 'close'
  
    ui:
      'image': 'img'
      'container': '.image-container'
      'slider': '.slider'
      'track': '.slider-track'
      'trim': '.image-trim'
  
    startSliding: (e) =>
      e.preventDefault()
      @model.startSizing()
      $('body').css('cursor', 'pointer')
      @disableTextSelect()
      @sliding = true
  
    startMoving: (e) =>
      e.preventDefault()
      @model.startMoving(e.pageX, e.pageY)
      $('body').css('cursor', 'move')
      @disableTextSelect()
  
    slide: (e) =>
      return if ! @sliding
      e.preventDefault()
  
      newPosition = e.pageX - @ui.track.offset().left - @ui.slider.width() / 2
      newPosition = 0 if newPosition < 0
      newPosition = @ui.track.width() - @ui.slider.width() if newPosition > @ui.track.width() - @ui.slider.width()
      factor = newPosition / (@ui.track.width() - @ui.slider.width())
      @model.size factor
      @model.refocusImage()

    stopSliding: (e) =>
      e.preventDefault()
      return if ! @sliding
      @sliding = false
      @enableTextSelect()
      $('body').css('cursor', 'default')
  
    moveImage: (e) =>
      e.preventDefault()
      @model.move e.pageX, e.pageY
        
    stopMovingImage: (e) =>
      e.preventDefault()
      @model.stopMoving()
      @enableTextSelect()
      $('body').css('cursor', 'default')

    clearImage: () =>
      @ui.image.removeAttr 'src'
      @model.clear()

    saveImageCoords: =>
      @imageStartOffset =
        left: parseInt(@ui.image.css 'left')
        top: parseInt(@ui.image.css 'top')
  
      @imageStartSize =
        width: @ui.image.width()
        height: @ui.image.height()
  
    disableTextSelect: =>
      window.getSelection().empty()
      $('body').on('selectstart', () => false)
  
    enableTextSelect: =>
      $('body').off('selectstart')

    modelEvents:
      'change:crop_x': 'refreshImagePositionX'
      'change:crop_y': 'refreshImagePositionY'
      'change:width': 'refreshImageWidth'
      'change:slider_factor': 'refreshSliderPosition'
      'change:url': 'loadImage'

    refreshImagePositionX: (model, x) ->
      @ui.image.css 'left', x

    refreshImagePositionY: (model, y) ->
      @ui.image.css 'top', y

    refreshImageWidth: (model, width) ->
      @ui.image.width width

    refreshSliderPosition: (model, slider_factor) ->
      @ui.slider.css 'left', ((@ui.track.width() - @ui.slider.width()) * slider_factor)

    loadImage: (model, url) =>
      @ui.image.attr('src', url)
        .load(
          (e) =>
            @model.startImage(
              @ui.image.width(),
              @ui.image.height(),
              @ui.trim.width(),
              @ui.trim.height(),
              parseInt(@ui.trim.css('border-left-width')),
              parseInt(@ui.trim.css('border-top-width')),
              parseInt(@ui.trim.css('border-bottom-width'))
            )
        )
        .error(
          (e) =>
            @controller.trigger 'new:image:error'
            )

    onRender: =>
      $('body').on 'mousemove', @slide
      $('body').on 'mousemove', @moveImage
      $('body').on 'mouseup', @stopSliding
      $('body').on 'mouseup', @stopMovingImage
  
    onClose: =>
      $('body').off 'mousemove', @slide
      $('body').off 'mousemove', @moveImage
      $('body').off 'mouseup', @stopSliding
      $('body').off 'mouseup', @stopMovingImage
