FK.App.module "Events.EventPage", (EventPage, App, Backbone, Marionette, $, _) ->
  
  @addInitializer () ->
    @listenTo App.vent, 'container:show', @show

  @show = (event) ->
    @close if @view
    
    @view = new EventPage.EventPageLayout
      model: event

    Backbone.history.navigate('events/show/' + event.id, trigger : false)

    App.mainRegion.show @view

  @close = () ->
    @view.close()


  class EventPage.EventPageLayout extends Marionette.Layout
    template: FK.Template('event_page')
    className: 'event-page'

    regions:
      eventCardRegion: '.event-card-region'
      eventDisqusRegion: '.event-disqus-region'

    onRender: () ->
      @eventCardRegion.show new EventPage.EventCard
        model: @model
