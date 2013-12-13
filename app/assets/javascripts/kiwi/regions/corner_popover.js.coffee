FK.App.module "Events.EventPage", (EventPage, App, Backbone, Marionette, $, _) ->
  class EventPage.CornerPopover extends Marionette.Region
    open: (view) =>
      @$el.popover
        html: true
        placement: 'bottom'
        title: 'Remind me of this event'
        content: view.el.innerHTML
        trigger: 'manual'
        container: '.event-info-container'
      @$el.popover 'show'

    onShow: (view) =>
      popover = @$el.closest('.event-info-container').find('.popover')
      popover.css('top', parseInt(popover.css('top')) + 7)
      popover.css('left', parseInt(popover.css('left')) + 111)
      popover.find('.arrow').css('left', '9%')

      view.once 'close', @destroyPopover
      popover.click (e) => e.stopPropagation()

    destroyPopover: () =>
      @$el.popover('destroy')
