FK.App.module "Events.EventForm", (EventForm, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @listenTo App.vent, 'container:new', @show
    @listenTo EventForm, 'create', @createEvent
    @listenTo FK.Data.events, 'created', @toAllEvents

  @show = () ->
    if @view
      @close()
  
    return if ! FK.CurrentUser.get('logged_in')

    @view = new EventForm.FormLayout()

    @view.on 'show', () =>
      @imageTrimmer = FK.App.ImageTrimmer.create '#image-region'
      @datePicker = FK.App.DatePicker.create '#datetime-region'

    FK.App.mainRegion.show @view

  @createEvent = () ->
    params = @view.value()
    params.user = FK.CurrentUser.get('name')
    _.extend params, @imageTrimmer.image()
    _.extend params, @datePicker.value()
    FK.Data.events.create(params)

  @toAllEvents = () ->
    Backbone.history.navigate('/events/all', trigger: true)

  @close = () ->
    @view.close()
    @imageTrimmer.close()
    @datePicker.close()
 

  class EventForm.FormLayout extends Backbone.Marionette.Layout
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
      @$('.save').html 'Saving...'
      EventForm.trigger('create')
      
    value: () ->
      window.serializeForm(@$el.find('input,select,textarea'))

    onRender: =>
      FK.Utils.RenderHelpers.populate_select_getter(@, 'country', FK.Data.countries, 'en_name')
      @$('.current_user').text(FK.CurrentUser.get('name'))
      @renderLocation()
