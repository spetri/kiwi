class FK.Views.EventForm extends Backbone.Marionette.ItemView
  className: "row-fluid"
  template: FK.Template('event_form')
  initialize: =>
    @model = new FK.Models.Event

  onRender: =>
    FK.Utils.RenderHelpers.populate_select_getter(@, 'country', FK.Data.countries, 'en_name') 
