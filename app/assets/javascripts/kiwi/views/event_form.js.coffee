class FK.Views.EventForm extends Backbone.Marionette.ItemView
  className: "row-fluid"
  template: FK.Template('event_form')
  events:
    'click .save': 'saveClicked'

  saveClicked: (e) =>
    e.preventDefault()
    FK.Data.events.create(window.serializeForm(@$el.find('input,select,textarea')))
    Backbone.history.navigate('/events/all', trigger: true)

  initialize: =>
    @model = new FK.Models.Event

  onRender: =>
    FK.Utils.RenderHelpers.populate_select_getter(@, 'country', FK.Data.countries, 'en_name') 
