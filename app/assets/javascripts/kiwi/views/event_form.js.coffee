class FK.Views.EventForm extends Backbone.Marionette.ItemView
  className: "row-fluid"
  template: FK.Template('event_form')
  events:
    'click .save': 'saveClicked'
    'change input[name=name]': 'validateName'
    'change input[name=location_type]': 'renderLocation'
  
  renderLocation: (e) => 
    if @$el.find('input[name=location_type]:checked').val() is "international"
      @$el.find('select[name=country]').attr('disabled','disabled')
    else
      @$el.find('select[name=country]').removeAttr('disabled')

  validateName: (e) =>
    @$el.find(".error").remove()
    if $(e.target).val().length > 79
      $("<div class=\"error\">Event is too long</div>").insertAfter(e.target)

  saveClicked: (e) =>
    e.preventDefault()
    params = window.serializeForm(@$el.find('input,select,textarea'))
    if params.datetime
      params.datetime = moment(params.datetime).utc() 
    FK.Data.events.create(params)
    Backbone.history.navigate('/events/all', trigger: true)

  initialize: =>
    @model = new FK.Models.Event

  onRender: =>
    FK.Utils.RenderHelpers.populate_select_getter(@, 'country', FK.Data.countries, 'en_name') 
    @renderLocation()
