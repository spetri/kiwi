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
