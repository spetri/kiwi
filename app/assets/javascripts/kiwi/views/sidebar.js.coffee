FK.App.module "Events.EventSidebar", (EventSidebar, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @listenTo App, 'start', @show

  @show = () ->
    @close() if @view

    @view = new EventSidebar.SidebarLayout()

    App.sidebarRegion.show @view

  @close = () ->
    @view.close()

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
      @most_discussed.show(new FK.Views.MostDiscussed(model: FK.Data.events.mostDiscussed()))
