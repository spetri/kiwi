FK.App.module "Events", (Events, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @listenTo App.vent, 'container:new', @startForm
    @listenTo App.vent, 'container:show', @startPage
    @listenTo App.vent, 'container:all', @startList

  @addFinalizer () ->
    @stopListening()

  @eventsListStartupData = () =>
    {
      eventStore: App.request('eventStore')
      subkasts: App.request('subkasts')
    }
    
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
