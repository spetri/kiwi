class FK.Components.ImageTrimmer extends Backbone.Marionette.ItemView
  template: FK.Template('image_trimmer')

  events:
    'mousedown .slider': 'startSliding'
    'mousedown .image-container': 'startMoving'

  ui:
    'image': 'img'
    'container': '.image-container'
    'slider': '.slider'
    'track': '.slider-track'

  startSliding: (e) =>
    e.preventDefault()
    @sliding = true
    @saveImageCoords()

  startMoving: (e) =>
    e.preventDefault()
    @movingImage = true
    @mouseStartOffset =
      left: e.pageX
      top: e.pageY
    @saveImageCoords()

  slide: (e) =>
    return if ! @sliding
    e.preventDefault()

    newPosition = e.pageX - @ui.track.offset().left - @ui.slider.width() / 2
    @ui.slider.css 'left', newPosition if newPosition > 0 and newPosition < @ui.track.width() - @ui.slider.width()
    @sizeImage()
    @refocusImage()

  stopSliding: (e) =>
    e.preventDefault()
    @sliding = false

  moveImage: (e) =>
    return if ! @movingImage
    e.preventDefault()
    left = @imageStartOffset.left + e.pageX - @mouseStartOffset.left
    top = @imageStartOffset.top + e.pageY - @mouseStartOffset.top
    @positionImage left, top

  stopMovingImage: (e) =>
    e.preventDefault()
    @movingImage = false

  startImage: =>
    @image =
      height: @ui.image.height()
      width:  @ui.image.width()
      minWidth: @ui.container.height() / @ui.image.height() * @ui.image.width()
    
    @sizeImage()
    @centerImage()

  saveImageCoords: =>
    @imageStartOffset =
      left: parseInt(@ui.image.css 'left')
      top: parseInt(@ui.image.css 'top')

    @imageStartSize =
      width: @ui.image.width()
      height: @ui.image.height()
 
  sizeImage: =>
    @ui.image.width( @image.minWidth + (@image.width - @image.minWidth) * @sliderFactor() )

  sliderFactor: =>
    (parseInt(@ui.slider.css('left')) + @ui.slider.width() / 2) / @ui.track.width()

  centerImage: =>
    overflowedRight = @ui.image.width() - @ui.container.width()
    overflowedBottom = @ui.image.height() - @ui.container.height()
    @positionImage -overflowedRight / 2, -overflowedBottom / 2

  refocusImage: =>
    newLeft = @imageStartOffset.left - (@ui.image.width() - @imageStartSize.width) / 2
    newTop = @imageStartOffset.top - (@ui.image.height() - @imageStartSize.height) / 2
    
    @positionImage newLeft, newTop

  positionImage: (x, y) =>
    @ui.image.css 'left', x
    @ui.image.css 'top', y

  onRender: =>
    $('body').on 'mousemove', @slide
    $('body').on 'mousemove', @moveImage
    $('body').on 'mouseup', @stopSliding
    $('body').on 'mouseup', @stopMovingImage
    _.delay @startImage, 50

  onClose: =>
    $('body').off 'mousemove', @slide
    $('body').off 'mousemove', @moveImage
    $('body').off 'mouseup', @stopSliding
    $('body').off 'mouseup', @stopMovingImage
