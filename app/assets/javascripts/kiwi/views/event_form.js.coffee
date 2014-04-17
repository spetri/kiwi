FK.App.module "Events.EventForm", (EventForm, App, Backbone, Marionette, $, _) ->

  @startWithParent = false

  @addInitializer (event) ->
    @user = App.request('currentUser')
    return App.execute('signInPage') if @user.get('logged_in') == false

    @event = event || new FK.Models.Event()
    @eventComponents = []

    @view = @.getBaseView()
    @addFinalizer () =>
      @view.close()

    @listenTo @event, 'saved', @toEvent
    @listenTo @event, 'change:user', @showBaseView
    @showBaseView()

  @showBaseView = () =>
    FK.App.mainRegion.show @view

  @addFinalizer () =>
    @stopListening()
    _.each @eventComponents, (child) ->
      child.close()

    @eventComponents = []

  @saveEvent = () ->
    @event.trigger('start:save')
    params =
      user: @user.get('username')

    _.each @eventComponents, (child) ->
      _.extend params, child.value()

    @event.clearImage()

    @event.initialUpvote() if @event.isNew()
    @event.save(params, { silent: true })

    return if not @event.isValid()

    @showSpinner()
    App.request('events').add(@event, merge: true)

  @getBaseView = () =>
    if @event.editAllowed(App.request('currentUser').get('username'))
      return @initFormView(@event)
    else
      return @initNotYourEventView()

  @initFormView = () =>
    form = new EventForm.FormLayout
      model: @event

    @saveButton = new EventForm.SaveButton()

    @listenTo @event, 'change:is_all_day', () =>
      if @event.get('is_all_day')
        $('.event_form_date').addClass('is_all_day')
      else
        $('.event_form_date').removeClass('is_all_day')


    form.on 'show', () =>
      @eventComponents.push FK.App.ImageTrimmer.create('#image-region', @event)
      @eventComponents.push FK.App.DatePicker.create('#datetime-region', @event)
      @eventComponents.push @view

      form.saveContainerRegion.show @saveButton

    @listenTo @saveButton, 'save', @saveEvent

    form

  @showSpinner = () =>
    @view.saveContainerRegion.show new EventForm.Spinner()

  @initNotYourEventView = () =>
    new EventForm.NotYourEventView()

  @toEvent = (event) ->
    App.vent.trigger 'container:show', event
