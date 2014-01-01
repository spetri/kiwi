FK.App.module "Events.EventSidebar", (EventSidebar, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @listenTo App.vent, 'container:all', @show
    @listenTo App.vent, 'container:show', @close
    @listenTo App.vent, 'container:new', @close

  @addFinalizer @close

  @show = () ->
    @view = new EventSidebar.SidebarLayout()
    @topRanked = new EventSidebar.TopRanked
      collection: FK.Data.events

    @topRanked.on 'itemview:clicked:event', (args) =>
      console.log args.model

    @view.on 'show', () =>
      @view.top_ranked.show @topRanked

    App.sidebarRegion.show @view

  @close = () ->
    @view.close() if @view

  class EventSidebar.SidebarLayout extends Backbone.Marionette.Layout
    className: "sidebar-nav"
    template: FK.Template('sidebar')
    regions:
      top_ranked: ".top-ranked"
      most_discussed: ".most-discussed"
