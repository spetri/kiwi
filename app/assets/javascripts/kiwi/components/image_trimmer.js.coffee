class FK.Components.ImageTrimmer extends Backbone.Marionette.ItemView
  template: FK.Template('image_trimmer')

  events:
    'mousedown .slider': 'startSlide'

  startSlide: (e) =>
    e.preventDefault
    @sliding = true
    $('body').css 'cursor', 'pointer'
    
  slide: (e) =>
    if ! @sliding
      return

    newPosition = e.pageX - @$('.slider-track').offset().left - @$('.slider').width() / 2
    @$('.slider').css 'left', newPosition if newPosition > 0 and newPosition < @$('.slider-track').width() - @$('.slider').width()

  stopSlide: (e) =>
    e.preventDefault
    @sliding = false
    $('body').css 'cursor', 'normal'

  initialize: =>
    @sliding = false
  
  onRender: =>
    $('body').mousemove @slide
    
    $('body').mouseup @stopSlide

  onClose: =>
    $('body').off 'mousemove', @slide
    $('body').off 'mouseup', @stopSlide
