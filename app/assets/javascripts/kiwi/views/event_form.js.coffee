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
    params =
      user: App.request('currentUser').get('username')

    _.each @eventComponents, (child) ->
      _.extend params, child.value()

    @event.clearImage()

    @event.save(params, { silent: true })
    App.request('events').add(@event, merge: true)

  @getBaseView = () =>
    if @event.editAllowed(App.request('currentUser').get('username'))
      return @initFormView(@event)
    else
      return @initNotYourEventView()

  @initFormView = () =>
    form = new EventForm.FormLayout
      model: @event

    form.on 'show', () =>
      @eventComponents.push FK.App.ImageTrimmer.create('#image-region', @event)
      @eventComponents.push FK.App.DatePicker.create('#datetime-region', @event)
      @eventComponents.push @view

    @listenTo form, 'save', @saveEvent

    form

  @initNotYourEventView = () =>
    new EventForm.NotYourEventView()

  @toEvent = (event) ->
    App.vent.trigger 'container:show', event

