FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  @startWithParent = false

  @addInitializer () ->
    @listenTo EventList, 'clicked:open', @triggerShowEvent
    @events = App.request('events')
    @view = new EventList.ListLayout()
    @eventBlocksView = new EventList.EventBlocks(collection: @events.asBlocks())
    
    @events.on 'add', =>
      @eventBlocksView.collection.reset @events.asBlocks().models

    @view.on 'show', =>
      @view.event_block.show @eventBlocksView

    @eventBlocksView.on 'itemview:click:more', @fetchMoreForBlock

    @view.onClose = () =>
      @stop()

    App.mainRegion.show @view

  @triggerShowEvent = (event) ->
    App.vent.trigger 'container:show', event

  @fetchMoreForBlock = (args) =>
    args.model.increaseLimit(3)
    args.model.fetchMore(3, @events)

  @close = () ->
    @view.close()
    @stopListening()

  class EventList.ListLayout extends Backbone.Marionette.Layout
    className: "row-fluid"
    regions:
      event_block: '#event_blocks'

    template: FK.Template('events')
