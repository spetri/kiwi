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
      return if ! @image || @image.undersized
      $('body').css('cursor', 'pointer')
      @disableTextSelect()
      @sliding = true
      @saveImageCoords()
  
    startMoving: (e) =>
      e.preventDefault()
      return if ! @image
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
      @ui.slider.css 'left', newPosition
      @sizeImage()
      @refocusImage()
  
    stopSliding: (e) =>
      e.preventDefault()
      return if ! @sliding
      @sliding = false
      @enableTextSelect()
      @broadcastImageSize()
  
    moveImage: (e) =>
      return if ! @movingImage
      e.preventDefault()
      left = @imageStartOffset.left + e.pageX - @mouseStartOffset.left
      top = @imageStartOffset.top + e.pageY - @mouseStartOffset.top
      @positionImage left, top
  
    stopMovingImage: (e) =>
      e.preventDefault()
      return if ! @movingImage
      @movingImage = false
      $('body').css('cursor', 'default')
      @broadcastImagePosition()

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
      @clearCoordinatesOnDom()
      
      @model.startImage(@ui.image.width(), @ui.image.height(), @ui.trim.width(), @ui.trim.height())

      @resetSlider()
      @sizeImage()
      @centerImage()
      @broadcastImageSize()
      @broadcastImagePosition()

    clearImage: () =>
      @clearCoordinatesOnDom()
      @ui.image.removeAttr 'src'
      @image =
        height: 0
        width: 0
        wToH: 0
        minWidth: 0

      @broadcastImageSize()
      @broadcastImagePosition()

    clearCoordinatesOnDom: () =>
      image = @ui.image
      coordinateAttrs = ['top', 'left', 'width']

      _.each coordinateAttrs, (coordinateAttr) =>
        image.css coordinateAttr, ''

    resetSlider: =>
      @ui.slider.css 'left', '0px'

    saveImageCoords: =>
      @imageStartOffset =
        left: parseInt(@ui.image.css 'left')
        top: parseInt(@ui.image.css 'top')
  
      @imageStartSize =
        width: @ui.image.width()
        height: @ui.image.height()
   
    sizeImage: (factor = 0) =>
      factor = @domSliderFactor() if (factor == 0)
      @ui.image.width(@model.adjustedWidth(factor))
  
    sliderFactor: (position) =>
      position / (@ui.track.width() - @ui.slider.width())
  
    domSliderFactor: =>
      @sliderFactor(parseInt(@ui.slider.css('left')))
  
    imageOutOfBounds: (width, x, y) =>
      @imageHorizontalOutOfBounds(width, x) || @imageVerticalOutOfBounds(width, y)

    imageHorizontalOutOfBounds: (width, x) =>
      x = x - parseInt(@ui.trim.css('border-left-width'))
      x > 0 || x + width < @ui.trim.width()

    imageVerticalOutOfBounds: (width, y) =>
      y = y - parseInt(@ui.trim.css('border-top-width'))
      height = Math.ceil width * @model.get('wToH')
      y > 0 || y + height < @ui.trim.height()
  
    centerImage: =>
      overflowedRight = @ui.image.width() - @ui.trim.outerWidth()
      overflowedBottom = @ui.image.height() - @ui.trim.outerHeight()
      @positionImage Math.floor(-overflowedRight / 2), Math.floor(-overflowedBottom / 2)
  
    refocusImage: =>
      newLeft = @imageStartOffset.left + (@imageStartSize.width - @ui.image.width()) / 2
      newTop = @imageStartOffset.top + (@imageStartSize.height - @ui.image.height()) / 2

      outFlowWidth = (@ui.trim.width() + parseInt(@ui.trim.css('border-left-width'))) - (@ui.image.width() + newLeft)
      outFlowHeight = (@ui.trim.height() + parseInt(@ui.trim.css('border-top-width'))) - (@ui.image.height() + newTop)

      outFlowWidth = 0 if outFlowWidth < 0
      outFlowHeight = 0 if outFlowHeight < 0
   
      @positionImage Math.floor(newLeft + outFlowWidth), Math.floor(newTop + outFlowHeight)

    positionImage: (x, y) =>
      @ui.image.css 'left', x if ! @imageHorizontalOutOfBounds(@ui.image.width(), x)
      @ui.image.css 'top', y if ! @imageVerticalOutOfBounds(@ui.image.width(), y)
  
    imagePosition: () =>
      {
        top: ((@ui.trim.offset().top + parseInt(@ui.trim.css('border-top-width'))) - @ui.image.offset().top) * @model.ratioToOriginalHeight()
        left: ((@ui.trim.offset().left + parseInt(@ui.trim.css('border-left-width'))) - @ui.image.offset().left) * @model.ratioToOriginalWidth()
      }

    imageSize: () =>
      {
        width: (@ui.trim.outerWidth() - (parseInt(@ui.trim.css('border-left-width')) + parseInt(@ui.trim.css('border-right-width')))) * @model.ratioToOriginalWidth()
        height: (@ui.trim.outerHeight() - (parseInt(@ui.trim.css('border-top-width')) + parseInt(@ui.trim.css('border-bottom-width')))) * @model.ratioToOriginalHeight()
      }

    broadcastImagePosition: () =>
      @model.setImagePosition @imagePosition()

    broadcastImageSize: () =>
      @model.setImageSize @imageSize()
 
    disableTextSelect: =>
      window.getSelection().empty()
      $('body').on('selectstart', () => false)
  
    enableTextSelect: =>
      $('body').off('selectstart')

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
