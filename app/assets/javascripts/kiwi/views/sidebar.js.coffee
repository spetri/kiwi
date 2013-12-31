FK.App.module "Events.EventSidebar", (EventSidebar, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @listenTo App.vent, 'container:all', @show
    @listenTo App.vent, 'container:show', @close
    @listenTo App.vent, 'container:new', @close

  @show = () ->
    @close()

    @view = new EventSidebar.SidebarLayout()

    App.sidebarRegion.show @view

  @close = () ->
    @view.close() if @view

  class EventSidebar.SidebarLayout extends Backbone.Marionette.Layout
    className: "sidebar-nav"
    template: FK.Template('sidebar')
    regions:
      top_ranked: ".top-ranked"
      most_discussed: ".most-discussed"

    initialize: =>
      FK.Data.events.on('all',@render)

    onRender: ->
      @top_ranked.show(new FK.Views.TopRanked(collection: FK.Data.events.topRanked()))
