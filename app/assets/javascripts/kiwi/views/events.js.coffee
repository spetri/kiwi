FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @listenTo App.vent, 'container:all', @show
    @listenTo App.vent, 'start', @show

  @show = () ->
    if @view
      @close()

    @view = new EventList.ListLayout()
    
    App.mainRegion.show @view

  class EventList.ListLayout extends Backbone.Marionette.Layout
    className: "row-fluid"
    regions:
      event_block: '#event_blocks'

    template: FK.Template('events')

    initialize: =>
      FK.Data.events.on('all',@render)

    onRender: ->
      @event_block.show(new FK.Views.EventBlocks(collection: FK.Data.events.asBlocks()))
