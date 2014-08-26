FK.App.module "Events", (Events, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @listenTo App.vent, 'container:new', @startForm
    @listenTo App.vent, 'container:show', @startPage
    @listenTo App.vent, 'container:all', @startList
    @listenTo App.vent, 'notfound', @startNotFound

  @addFinalizer () ->
    @stopListening()

  @eventsListStartupData = () =>
    {
      eventStore: App.request('eventStore')
      subkasts: App.request('subkasts')
      mySubkasts: App.request('mySubkasts')
      config: App.request('eventConfig')
      topRanked: App.request('eventStore').topRanked
    }

  @startNotFound = () ->
    Events.stop()
    Events.start()
    Events.NotFound.start()

  @startForm = (event) ->
    Events.stop()
    Events.start()
    Events.EventForm.start(event)

  @startPage = (event) ->
    Events.stop()
    Events.start()
    Events.EventPage.start(event)

  @startList = () ->
    Events.stop()
    Events.start()
    Events.EventList.start(@eventsListStartupData())
