FK.App.module "Events.EventSidebar", (EventSidebar, App, Backbone, Marionette, $, _) ->

  @addInitializer () =>
    @listenTo App.vent, 'container:all', @show
    @listenTo App.vent, 'container:show', @close
    @listenTo App.vent, 'container:new', @close

  @addFinalizer () =>
    @close()

  @show = () ->
    @events = App.request('events')
    @topRankedEvents = @events.topRankedProxy(10, moment(), moment().add('days', 7))

    @view = new EventSidebar.SidebarLayout()
    @topRankedEventsView = new EventSidebar.TopRanked
      collection: @topRankedEvents

    @topRankedEventsView.on 'itemview:clicked:event', (args) =>
      @toEvent args.model

    @view.on 'show', () =>
      @view.top_ranked.show @topRankedEventsView

    App.sidebarRegion.show @view

  @toEvent = (event) ->
    App.vent.trigger 'container:show', event

  @close = () =>
    @view.close() if @view

  class EventSidebar.SidebarLayout extends Backbone.Marionette.Layout
    className: "sidebar-nav"
    template: FK.Template('sidebar')
    regions:
      top_ranked: ".top-ranked"
      most_discussed: ".most-discussed"
