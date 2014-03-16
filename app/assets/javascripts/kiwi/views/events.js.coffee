FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  @startWithParent = false

  @addInitializer () ->
    # get the dependencies:
    @events = App.request('events')
    @eventStore = App.request('eventStore')
    @eventBlocks = App.request('eventStore').blocks

    # creating the views:
    @view = new EventList.ListLayout()
    @eventBlocksView = new EventList.EventBlocks
      collection: @eventBlocks

    @sidebar = App.Sidebar.create(@sidebarConfig)

    # binding the events:
    @view.on 'show', =>
      @view.sidebar.show @sidebar.layout
      @view.event_block.show @eventBlocksView

    @listenTo @eventBlocksView,'block:event:click:open', @triggerShowEventDeep

    @view.onClose = () =>
      @stop()

    Backbone.history.navigate('events/all', trigger : false)

    App.mainRegion.show @view

    $(document).scroll (e) =>
      $doc = $(e.target)
      $window = $(window)

      percentage = $doc.scrollTop() / ($doc.height() - $window.height())

      @fetchMoreBlocks() if percentage > 0.9

  @triggerShowEventDeep = (block, event) ->
    App.vent.trigger 'container:show', event.model

  @fetchMoreBlocks = () =>
    @eventStore.loadNextEvents(5)

  @addFinalizer () =>
    $(document).off('scroll')
    @view.close()
    @eventBlocksView.close()

    # keep a copy of the sidebar configuration:
    @sidebarConfig = @sidebar.value()

    @sidebar.close()
    @stopListening

  class EventList.ListLayout extends Backbone.Marionette.Layout
    className: "container"
    id: "home-page"
    regions:
      event_block: '#event-blocks-region'
      sidebar: '#sidebar-region'

    template: FK.Template('events')
