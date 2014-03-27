FK.App.module "Events.EventForm", (EventForm, App, Backbone, Marionette, $, _) ->
  class EventForm.Spinner extends Marionette.ItemView
    tagName: 'i'
    className: 'icon-spinner icon-spin icon-2x'
    template: FK.Template('spinner')
