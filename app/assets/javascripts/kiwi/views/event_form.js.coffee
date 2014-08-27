FK.App.module "Events.EventForm", (EventForm, App, Backbone, Marionette, $, _) ->

  @startWithParent = false

  @addInitializer (event) ->
    @user = App.request('currentUser')
    return App.execute('signInPage') if @user.get('logged_in') == false

    @eventStore = App.request('eventStore')
    @events = App.request('events')
    @subkasts = App.request('subkasts')

    @event = event || new FK.Models.Event()
    @eventComponents = []

    @view = @.getBaseView()
    @addFinalizer () =>
      @view.close()

    @listenTo @event, 'saved', @toEvent
    @listenTo @event, 'change:user', @showBaseView
    @showBaseView()

    @userSetsCountry()

    if event
      Backbone.history.navigate 'events/edit/' + event.id, trigger: false
    else
      Backbone.history.navigate 'events/new/', trigger: false

  @userSetsCountry = () =>
    if @user.hasLastPostedCountry() and @event.isNew()
      @view.setCountry(@user.lastPostedCountry())

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
    saving = @event.save(params, { silent: true })

    return if not @event.isValid()

    #TODO: Find a happy home for this that is more concerned with what happens to users
    if @event.isNational()
      @user.setLastPostedCountry(@event.get('country'))

    @showSpinner()
    @eventStore.addNewEventToBlock(@event)

  @getBaseView = () =>
    if @event.editAllowed(@user.get('username'))
      return @initFormView(@event)
    else
      return @initNotYourEventView()

  @initFormView = () =>
    form = new EventForm.FormLayout
      model: @event

    @saveButton = new EventForm.SaveButton()

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
