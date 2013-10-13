class FK.Views.EventForm extends Backbone.Marionette.Layout
  className: "row-fluid"
  template: FK.Template('event_form')

  events:
    'click .save': 'saveClicked'
    'change input[name=name]': 'validateName'
    'change input[name=location_type]': 'renderLocation'

  validateName: (e) =>
    @$el.find(".error").remove()
    if $(e.target).val().length > 79
      $("<div class=\"error\">Event is too long</div>").insertAfter(e.target)
  
  renderLocation: (e) =>
    if @$el.find('input[name=location_type]:checked').val() is "international"
      @$el.find('select[name=country]').attr('disabled','disabled')
    else
      @$el.find('select[name=country]').removeAttr('disabled')
      

  saveClicked: (e) =>
    e.preventDefault()
    @$('.save').addClass 'disabled'
    @$('.save').html 'Hang tight...'
    params = window.serializeForm(@$el.find('input,select,textarea'))
    params.user = FK.CurrentUser.get('name')

    _.extend params, @imageTrimmer.image()
    _.extend params, @datePicker.value()
    FK.Data.events.create(params)

  initialize: =>
    @model = new FK.Models.Event
    @listenTo FK.Data.events, 'created', @toAllEvents

  toAllEvents: (attrs) =>
    Backbone.history.navigate('/events/all', trigger: true)

  onRender: =>
    @$('.current_user').text(FK.CurrentUser.get('name'))
    FK.Utils.RenderHelpers.populate_select_getter(@, 'country', FK.Data.countries, 'en_name')

  onShow: =>
    @imageTrimmer = FK.App.ImageTrimmer.create '#image-region'
    @datePicker = FK.App.DatePicker.create '#datetime-region'

  onClose: =>
    @imageTrimmer.close()
    @datePicker.close()
