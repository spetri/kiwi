class FK.Components.ImageTrimmer extends Backbone.Marionette.ItemView
  template: FK.Template('image_trimmer')

  events:
    'mousedown .slider': 'startSlide'

  ui:
    'image': 'img'
    'container': '.image-container'
    'slider': '.slider'
    'track': '.slider-track'

  startSlide: (e) =>
    e.preventDefault
    @sliding = true
    $('body').css 'cursor', 'pointer'
    
  initialize: =>
    @sliding = false
    @image =
      height: 0
      width: 0
      ratio: 0

  slide: (e) =>
    if ! @sliding
      return

    newPosition = e.pageX - @$('.slider-track').offset().left - @$('.slider').width() / 2
    @$('.slider').css 'left', newPosition if newPosition > 0 and newPosition < @$('.slider-track').width() - @$('.slider').width()
    @sizeImage()

  sliderFactor: =>
    (parseInt(@ui.slider.css('left')) + @ui.slider.width() / 2) / @ui.track.width()

  stopSlide: (e) =>
    e.preventDefault
    @sliding = false
    $('body').css 'cursor', 'normal'

  startImage: =>
    @image.height = @ui.image.height()
    @image.width = @ui.image.width()
    @image.ratio = @image.height / @image.width
    @image.minWidth = @imageMatchingWidth @ui.container.height()
    
    @sizeImage()

  sizeImage: =>
    settingWidth = @image.minWidth + (@image.width - @image.minWidth) * @sliderFactor()
    @ui.image.width settingWidth
    @centerImage()

  imageMatchingWidth: (height) =>
    return height / @image.ratio
 
  centerImage: =>
    overflowedRight = @ui.image.width() - @ui.container.width()
    overflowedBottom = @ui.image.height() - @ui.container.height()
    @ui.image.css 'top', -overflowedBottom / 2
    @ui.image.css 'left', -overflowedRight / 2
 
  onRender: =>
    $('body').on 'mousemove', @slide
    $('body').on 'mouseup', @stopSlide
    _.delay @startImage, 50

  onClose: =>
    $('body').off 'mousemove', @slide
    $('body').off 'mouseup', @stopSlide
