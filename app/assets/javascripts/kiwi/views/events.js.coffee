FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  @startWithParent = false

  @addInitializer () ->
    @listenTo EventList, 'clicked:open', @triggerShowEvent
    @view = new EventList.ListLayout()

    @view.onClose = () =>
      @stop()

    App.mainRegion.show @view

  @triggerShowEvent = (event) ->
    App.vent.trigger 'container:show', event

  @close = () ->
    @view.close()
    @stopListening()

  class EventList.ListLayout extends Backbone.Marionette.Layout
    className: "row-fluid"
    regions:
      event_block: '#event_blocks'

    template: FK.Template('events')

    initialize: =>
      FK.Data.events.on('add remove',@render)

    onRender: ->
      @event_block.show(new EventList.EventBlocks(collection: FK.Data.events.asBlocks()))
