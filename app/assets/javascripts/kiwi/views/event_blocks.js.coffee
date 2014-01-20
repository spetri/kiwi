FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  class EventList.EventBlocks extends Backbone.Marionette.CollectionView
    itemView: EventList.EventBlock
    className: 'event-blocks'
    itemViewEventPrefix: 'block'
    itemViewOptions: (model) =>
      return {
        collection: model.events
      }
    appendHtml: (collectionView, itemView, index) =>
      return collectionView.$el.prepend(itemView.el) if index is 0
      atIndex = collectionView.$el.children().eq(index)
      return atIndex.before(itemView.el) if atIndex.length
      return collectionView.$el.append(itemView.el)
