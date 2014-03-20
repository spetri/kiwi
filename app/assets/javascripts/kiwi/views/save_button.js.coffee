FK.App.module "Events.EventForm", (EventForm, App, Backbone, Marionette, $, _) ->
  class EventForm.SaveButton extends Marionette.ItemView
    tagName: 'button'
    className: 'btn btn-success'
    template: FK.Template('save_button')
    triggers:
      'click': 'save'
