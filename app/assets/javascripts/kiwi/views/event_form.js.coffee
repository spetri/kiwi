FK.App.module "Events.EventForm", (EventForm, App, Backbone, Marionette, $, _) ->

  @startWithParent = false

  @addInitializer (event) ->
    @event = event || new FK.Models.Event()
    @eventComponents = []

    @notYourEventView = @initNotYourEventView()
    @formView = @initFormView(@event)
    @eventComponents.push @formView

    @listenTo @formView, 'save', @saveEvent
    @listenTo @event, 'saved', @toEvent
    @listenTo @event, 'sync', @imageStartUp
    @listenTo @event, 'change:user', @showAllowedView

    @showAllowedView()

  @addFinalizer () =>
    @stopListening()
    _.each @eventComponents, (child) ->
      child.close()

    @notYourEventView.close()
    @eventComponents = []
 
  @saveEvent = () ->
    params =
      user: App.request('currentUser').get('username')

    _.each @eventComponents, (child) ->
      _.extend params, child.value()

    @event.clearImage()

    @event.save(params, { silent: true })
    FK.Data.events.add(@event, merge: true)

  @showAllowedView = () =>
    
    # cleanup a potentially old view
    @view.close() if @view

    if @event.editAllowed(App.request('currentUser').get('username'))
      @view = @formView
    else
      @view = @notYourEventView

    FK.App.mainRegion.show @view

  @initFormView = (event) =>
    form = new EventForm.FormLayout
      model: event

    form.on 'show', () =>
      @imageTrimmer = FK.App.ImageTrimmer.create '#image-region'
      @imageStartup @event
      @eventComponents.push @imageTrimmer
      @datePicker = FK.App.DatePicker.create '#datetime-region', @event
      @eventComponents.push @datePicker

    form

  @initNotYourEventView = () =>
    new EventForm.NotYourEventView()

  @imageStartup = (event) =>
    if event.get('originalUrl')
      @setImageUrl event, event.get('originalUrl')
      @setImageSize event, event.get('width')
      @imageTrimmer.setPosition event.get('crop_x'), event.get('crop_y')

  @setImageUrl = (event, url) =>
    @imageTrimmer.newImage url, 'remote'

  @setImageSize = (event, width) =>
    @imageTrimmer.setWidth width

  @setImagePositionX = (event, x) =>
    @imageTrimmer.setPosition x, event.get('crop_y')

  @setImagePositionY = (event, y) =>
    @imageTrimmer.setPosition event.get('crop_x'), y

  @toEvent = (event) ->
    App.vent.trigger 'container:show', event

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
      @trigger 'save'

    modelEvents:
      'change:name': 'refreshName'
      'change:location': 'refreshLocation'
      'change:country': 'refreshLocation'
      'change:description': 'refreshDescription'

    refreshName: (event) ->
      @$('#name').val event.get('name')

    refreshLocation: (event) ->
      @$('[name="location_type"][value="' + event.get('location_type') + '"]').attr('checked', 'checked')
      @$('[name="country"] [value="' + event.get('country') + '"]').attr('selected', 'selected')

    refreshDescription: (event) ->
      @$('[name="description"]').val(event.get('description'))

    value: () ->
      window.serializeForm(@$el.find('input,select,textarea'))

    onRender: =>
      FK.Utils.RenderHelpers.populate_select_getter(@, 'country', FK.Data.countries, 'en_name')
      @refreshName @model
      @refreshLocation @model
      @refreshDescription @model
      @renderLocation()
