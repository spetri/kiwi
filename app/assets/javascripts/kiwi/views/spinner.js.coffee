FK.App.module "Events.EventForm", (EventForm, App, Backbone, Marionette, $, _) ->
  class EventForm.Spinner extends Marionette.ItemView
    tagName: 'i'
    className: 'fa fa-spinner fa-spin fa-2x'
    template: FK.Template('spinner')
