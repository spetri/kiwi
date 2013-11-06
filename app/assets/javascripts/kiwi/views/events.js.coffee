FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @listenTo App.vent, 'container:all', @show
    @listenTo EventList, 'clicked:open', @triggerShowEvent

  @show = () ->
    @close() if @view

    @view = new EventList.ListLayout()
    
    App.mainRegion.show @view

  @triggerShowEvent = (event) ->
    App.vent.trigger 'container:show', event


  @close = () ->
    @view.close()

  class EventList.ListLayout extends Backbone.Marionette.Layout
    className: "row-fluid"
    regions:
      event_block: '#event_blocks'

    template: FK.Template('events')

    initialize: =>
      FK.Data.events.on('all',@render)

    onRender: ->
      @event_block.show(new EventList.EventBlocks(collection: FK.Data.events.asBlocks()))
