FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  class EventList.EventBlocks extends Backbone.Marionette.CollectionView
    itemView: EventList.EventBlock
    className: 'event-blocks'
    itemViewOptions: (model) =>
      return {
        collection: model.events
      }
