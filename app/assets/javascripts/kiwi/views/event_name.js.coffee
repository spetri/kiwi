FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  class EventList.EventName extends Marionette.ItemView
    template: FK.Template('event_name')
    tagName: 'a'
    className: 'event-name'
    triggers:
      'click': 'clicked:event'
