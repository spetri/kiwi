FK.App.module "Events.EventPage", (EventPage, App, Backbone, Marionette, $, _) ->
  
  @addInitializer () ->
    @listenTo App.vent, 'container:show', @show

  @show = (event) ->
    @close() if @view
    
    @view = new EventPage.EventPageLayout
      model: event

    @eventCardView = new EventPage.EventCard
      model: event

    @listenTo @eventCardView, 'click:edit', @triggerEditEvent

    @view.onShow = () =>
      @view.eventCardRegion.show @eventCardView

    Backbone.history.navigate('events/show/' + event.id, trigger : false)

    App.mainRegion.show @view

  @triggerEditEvent = (args) ->
    App.vent.trigger 'container:new', args.model

  @close = () ->
    @view.close()


  class EventPage.EventPageLayout extends Marionette.Layout
    template: FK.Template('event_page')
    className: 'event-page'

    regions:
      eventCardRegion: '.event-card-region'
      eventDisqusRegion: '.event-disqus-region'
