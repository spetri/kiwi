class FK.Components.ImageTrimmer extends Backbone.Marionette.ItemView
  template: FK.Template('image_trimmer')

  events:
    'mousedown .slider': 'startSlide'
    'mousedown .image-container': 'startMoving'

  ui:
    'image': 'img'
    'container': '.image-container'
    'slider': '.slider'
    'track': '.slider-track'

  startSlide: (e) =>
    e.preventDefault
    @sliding = true
    @saveImageCoords()

  startMoving: (e) =>
    e.preventDefault
    @movingImage = true
    @mouseStartOffset =
      left: e.pageX
      top: e.pageY
    @saveImageCoords()
    
  initialize: =>
    @sliding = false
    @image =
      height: 0
      width: 0
      ratio: 0

  slide: (e) =>
    return if ! @sliding

    e.preventDefault()

    newPosition = e.pageX - @$('.slider-track').offset().left - @$('.slider').width() / 2
    @$('.slider').css 'left', newPosition if newPosition > 0 and newPosition < @$('.slider-track').width() - @$('.slider').width()
    @sizeImage()

  sliderFactor: =>
    (parseInt(@ui.slider.css('left')) + @ui.slider.width() / 2) / @ui.track.width()

  stopSlide: (e) =>
    e.preventDefault()
    @sliding = false
    $('body').css 'cursor', 'normal'

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

  startImage: =>
    @image.height = @ui.image.height()
    @image.width = @ui.image.width()
    @image.ratio = @image.height / @image.width
    @image.minWidth = @imageMatchingWidth @ui.container.height()
    @saveImageCoords()
    
    @sizeImage()
    @centerImage()

  sizeImage: =>
    settingWidth = @image.minWidth + (@image.width - @image.minWidth) * @sliderFactor()
    @ui.image.width settingWidth

    newLeft = @imageStartOffset.left - (@ui.image.width() - @imageStartSize.width) / 2
    newTop = @imageStartOffset.top - (@ui.image.height() - @imageStartSize.height) / 2
    
    @positionImage newLeft, newTop

  imageMatchingWidth: (height) =>
    return height / @image.ratio

  centerImage: =>
    overflowedRight = @ui.image.width() - @ui.container.width()
    overflowedBottom = @ui.image.height() - @ui.container.height()
    @positionImage -overflowedRight / 2, -overflowedBottom / 2

  positionImage: (x, y) =>
    @ui.image.css 'left', x
    @ui.image.css 'top', y

  saveImageCoords: =>
    @imageStartOffset =
      left: parseInt(@ui.image.css 'left')
      top: parseInt(@ui.image.css 'top')

    @imageStartSize =
      width: @ui.image.width()
      height: @ui.image.height()
 
  onRender: =>
    $('body').on 'mousemove', @slide
    $('body').on 'mousemove', @moveImage
    $('body').on 'mouseup', @stopSlide
    $('body').on 'mouseup', @stopMovingImage
    _.delay @startImage, 50

  onClose: =>
    $('body').off 'mousemove', @slide
    $('body').off 'mousemove', @moveImage
    $('body').off 'mouseup', @stopSlide
    $('body').off 'mouseup', @stopMovingImage
