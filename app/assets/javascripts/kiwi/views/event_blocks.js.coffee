FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  class EventList.EventBlocks extends Backbone.Marionette.CollectionView
    itemView: FK.Views.EventBlock

