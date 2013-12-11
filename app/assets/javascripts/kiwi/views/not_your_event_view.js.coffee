FK.App.module 'Events.EventForm', (EventForm, App, Backbone, Marionette, $, _) ->
  class EventForm.NotYourEventView extends Marionette.ItemView
    template: FK.Template('not_your_event_template')
