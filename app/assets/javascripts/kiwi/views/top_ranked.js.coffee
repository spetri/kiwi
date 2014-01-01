FK.App.module "Events.EventSidebar", (EventSidebar, App, Backbone, Marionette, $, _) ->

  class EventSidebar.TopRanked extends Marionette.CompositeView
    template: FK.Template('top_ranked')
    className: 'top-ranked'
    itemView: EventSidebar.EventName
    itemViewContainer: 'ol'
