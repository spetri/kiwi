FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  class EventList.Sidebar extends Marionette.CompositeView
    template: FK.Template('sidebar')
    className: 'sidebar'
    itemView: EventList.EventName
    itemViewContainer: 'ul'
