FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  class EventList.EventBlock extends Backbone.Marionette.CompositeView
    template: FK.Template('event_block')
    className: 'event-block'
    itemViewContainer: '.events'
    itemView: EventList.EventCollapsed
    templateHelpers: () =>
      return {
        isToday: () => @model.isToday()
      }
    triggers:
      'click .btn': 'click:more'

    modelEvents:
      'change:more_events_available': 'refreshMoreEventsDisabled'

    refreshMoreEventsDisabled: (block, moreEventsAvailable) =>
      if (moreEventsAvailable)
        @$('.btn').removeClass('disabled')
        @$('.btn').prop('disabled', false)
      else
        @$('.btn').addClass('disabled')
        @$('.btn').prop('disabled', true)

    onRender: () =>
      @refreshMoreEventsDisabled(@model, @model.get('more_events_available'))
