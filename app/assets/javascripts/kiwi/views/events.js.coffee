FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  @startWithParent = false

  @addInitializer () ->
    
    @events = App.request('events')
    @eventStore = App.request('eventStore')
    @eventBlocks = App.request('eventStore').blocks
    @topRankedEvents = App.request('eventStore').topRanked

    @view = new EventList.ListLayout()
    @eventBlocksView = new EventList.EventBlocks
      collection: @eventBlocks

    @topRankedEventsView = new EventList.TopRanked
      collection: @topRankedEvents
    
    @view.on 'show', =>
      @view.sidebar.show @topRankedEventsView
      @view.event_block.show @eventBlocksView


    @listenTo @eventBlocksView, 'block:click:more', @fetchMoreForBlock
    @listenTo @eventBlocksView,'block:event:click:open', @triggerShowEventDeep
    @listenTo @topRankedEventsView, 'itemview:clicked:event', @triggerShowEvent

    @view.onClose = () =>
      @stop()

    App.mainRegion.show @view

    $(document).scroll (e) =>
      $doc = $(e.target)
      $window = $(window)

      percentage = $doc.scrollTop() / ($doc.height() - $window.height())

      @fetchMoreBlocks() if percentage > 0.9

  @triggerShowEvent = (event) ->
    App.vent.trigger 'container:show', event.model

  @triggerShowEventDeep = (block, event) ->
    App.vent.trigger 'container:show', event.model

  @fetchMoreForBlock = (args) =>
    args.model.increaseLimit(3)
    args.model.fetchMore(3, @events)

  @fetchMoreBlocks = () =>
    @eventStore.moreBlocks(1)

  @addFinalizer () =>
    $(document).off('scroll')
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
