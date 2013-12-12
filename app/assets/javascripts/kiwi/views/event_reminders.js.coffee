FK.App.module "Events.EventPage", (EventPage, App, Backbone, Marionette, $, _) ->
  class EventPage.EventReminders extends Marionette.ItemView
    template: FK.Template('event_reminders')
    className: 'event-reminders-container'
