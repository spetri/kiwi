FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  @startWithParent = false

  @addInitializer () ->
    
    @events = App.request('events')
    @eventBlocks = new FK.Collections.EventBlockList()
    @topRankedEvents = @events.topRankedProxy(10, moment(), moment().add('days', 7))
    
    @view = new EventList.ListLayout()
    @eventBlocksView = new EventList.EventBlocks
      collection: @eventBlocks

    @topRankedEventsView = new EventList.TopRanked
      collection: @topRankedEvents
    
    @events.once 'sync', @loadBlocks

    @view.on 'show', =>
      @view.sidebar.show @topRankedEventsView
      @view.event_block.show @eventBlocksView


    @listenTo @eventBlocksView, 'block:click:more', @fetchMoreForBlock
    @listenTo @eventBlocksView,'block:event:click:open', @triggerShowEventDeep
    @listenTo @topRankedEventsView, 'itemview:clicked:event', @triggerShowEvent

    @view.onClose = () =>
      @stop()

    App.mainRegion.show @view
    @loadBlocks()

  @triggerShowEvent = (event) ->
    App.vent.trigger 'container:show', event.model

  @triggerShowEventDeep = (block, event) ->
    App.vent.trigger 'container:show', event.model

  @fetchMoreForBlock = (args) =>
    args.model.increaseLimit(3)
    args.model.fetchMore(3, @events)

  @loadBlocks = =>
    @eventBlocks.reset @events.asBlocks()

  @addFinalizer () =>
    @view.close()
    @eventBlocksView.close()
    @topRankedEventsView.close()
    @stopListening
    

  class EventList.ListLayout extends Backbone.Marionette.Layout
    className: "container"
    regions:
      event_block: '#event-blocks-region'
      sidebar: '#sidebar-region'

    template: FK.Template('events')
