FK.App.module "ImageTrimmer", (ImageTrimmer, App, Backbone, Marionette, $, _) ->

  class ImageTrimmer.ImageTrimmerView extends Marionette.ItemView
    template: FK.Template('image_trimmer')
    className: 'image-trimmer-dialog'
 
    initialize: (options) ->
      @controller = options.controller
      @listenTo @controller, 'new:image:ready', @startImage
      @listenTo @controller, 'new:image', @loadImage
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
      return if not @model.sizable()
      $('body').css('cursor', 'pointer')
      @disableTextSelect()
      @sliding = true
      @saveImageCoords()
  
    startMoving: (e) =>
      e.preventDefault()
      return if not @model.movable()
      $('body').css('cursor', 'move')
      @movingImage = true
      @disableTextSelect()
      @mouseStartOffset =
        left: e.pageX
        top: e.pageY
      @saveImageCoords()
  
    slide: (e) =>
      return if ! @sliding
      e.preventDefault()
  
      newPosition = e.pageX - @ui.track.offset().left - @ui.slider.width() / 2
      newPosition = 0 if newPosition < 0
      newPosition = @ui.track.width() - @ui.slider.width() if newPosition > @ui.track.width() - @ui.slider.width()
      @model.set 'slider_factor', @sliderFactor(newPosition)
      @refocusImage()

    sliderFactor: (position) =>
      position / (@ui.track.width() - @ui.slider.width())
  
    stopSliding: (e) =>
      e.preventDefault()
      return if ! @sliding
      @sliding = false
      @enableTextSelect()
      $('body').css('cursor', 'default')
  
    moveImage: (e) =>
      return if ! @movingImage
      e.preventDefault()
      left = @imageStartOffset.left + e.pageX - @mouseStartOffset.left
      top = @imageStartOffset.top + e.pageY - @mouseStartOffset.top
      @model.positionImage(left, top)
  
    stopMovingImage: (e) =>
      e.preventDefault()
      return if ! @movingImage
      @movingImage = false
      $('body').css('cursor', 'default')

    loadImage: (url) =>
      @ui.image.attr('src', url)
        .load(
          (e) =>
            @controller.trigger 'new:image:ready'
            )
        .error(
          (e) =>
            @controller.trigger 'new:image:error'
            )

    startImage: () =>
      
      @model.startImage(
        @ui.image.width(),
        @ui.image.height(),
        @ui.trim.width(),
        @ui.trim.height(),
        parseInt(@ui.trim.css('border-left-width')),
        parseInt(@ui.trim.css('border-top-width')),
        parseInt(@ui.trim.css('border-bottom-width'))
      )

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
  
    refocusImage: =>
      newLeft = @imageStartOffset.left + (@imageStartSize.width - @ui.image.width()) / 2
      newTop = @imageStartOffset.top + (@imageStartSize.height - @ui.image.height()) / 2

      outFlowWidth = (@ui.trim.width() + parseInt(@ui.trim.css('border-left-width'))) - (@ui.image.width() + newLeft)
      outFlowHeight = (@ui.trim.height() + parseInt(@ui.trim.css('border-top-width'))) - (@ui.image.height() + newTop)

      outFlowWidth = 0 if outFlowWidth < 0
      outFlowHeight = 0 if outFlowHeight < 0
   
      @model.positionImage Math.floor(newLeft + outFlowWidth), Math.floor(newTop + outFlowHeight)

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

    refreshImagePositionX: (model, x) ->
      @ui.image.css 'left', x

    refreshImagePositionY: (model, y) ->
      @ui.image.css 'top', y

    refreshImageWidth: (model, width) ->
      @ui.image.width width

    refreshSliderPosition: (model, slider_factor) ->
      @ui.slider.css 'left', ((@ui.track.width() - @ui.slider.width()) * slider_factor)

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
