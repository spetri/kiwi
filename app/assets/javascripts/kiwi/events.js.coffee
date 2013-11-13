FK.App.module "Events", (Events, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @listenTo App.vent, 'container:new', @startForm
    @listenTo App.vent, 'container:show', @startPage
    @listenTo App.vent, 'container:all', @startList
    
  @startForm = (event) ->
    Events.EventForm.start(event)

  @startPage = (event) ->
    Events.EventPage.start(event)

  @startList = () ->
    Events.EventList.start()
