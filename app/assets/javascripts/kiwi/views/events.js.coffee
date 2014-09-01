FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  @startWithParent = false

  @addInitializer (startupData) ->

    @eventStore = startupData.eventStore
    @events = @eventStore.events
    @eventBlocks = @eventStore.blocks
    @eventConfig = startupData.config
    @subkasts = startupData.subkasts
    @mySubkasts = startupData.mySubkasts
    @topRanked = startupData.topRanked

    sidebarOptions = @sidebarStartupData()

    # creating the views:
    @view = new EventList.ListLayout()
    @eventBlocksView = new EventList.EventBlocks
      collection: @eventBlocks

    @sidebar = App.Sidebar.create(sidebarOptions)

    # binding the events:
    @view.on 'show', =>
      @view.sidebar.show @sidebar.layout
      @view.event_block.show @eventBlocksView
      @resumePosition()

    @listenTo @eventBlocksView, 'block:event:click:open', @triggerShowEventDeep
    @listenTo @eventBlocksView, 'block:event:click:reminders', @showReminders
    @listenTo @events, 'remove reset', @resetPosition
    @listenTo @eventConfig, 'change:subkasts', @setUrl

    @view.onClose = () =>
      @stop()

    @position = App.request('scrollPosition')

    App.mainRegion.show @view

    @setUrl()

    #TODO this spams on the MAC when scrolling the bottom of the pags
    $(document).scroll(_.throttle(@fetchMoreAfterScroll, 1000))


  @fetchMoreAfterScroll = (e) =>
    @savePosition()
    $doc = $(e.target)
    $window = $(window)

    percentage = $doc.scrollTop() / ($doc.height() - $window.height())

    @fetchMoreBlocks() if percentage > 0.8


  @sidebarStartupData = () =>
    {
      mySubkasts: @mySubkasts
      config: @eventConfig
      topRanked: App.request('eventStore').topRanked
    }

  @setUrl = () =>
    subkast = @eventStore.getSingleSubkast()
    if not subkast or subkast is 'ALL'
      Backbone.history.navigate('/', trigger : false)
    else
      url = @subkasts.getUrlByCode(subkast)
      Backbone.history.navigate(url, trigger: false)


  @savePosition = () =>
    @position = $(document).scrollTop()

  @resumePosition = () =>
    # - 5 because if you come back to a page on exactly the same place, chrome tries to handle
    # bringing back the scroll position, which conflicts with this logic
    $(document).scrollTop(@position - 5) if @position > 0

  @resetPosition = () =>
    @position = undefined

  @triggerShowEventDeep = (block, event) ->
    App.vent.trigger 'container:show', event.model

  @showReminders = (blockView, eventView, args) =>
    @remindersComponent = FK.App.Reminders.create({event: args.model, container: eventView.ui.remindersContainer })

  @fetchMoreBlocks = () =>
    @eventStore.loadNextEvents(10)

  @addFinalizer () =>
    $(document).off('scroll')
    @view.close()
    @eventBlocksView.close()

    @sidebar.close()
    @stopListening
    App.execute('saveScrollPosition', @position)
    @position = undefined

  class EventList.ListLayout extends Backbone.Marionette.Layout
    className: "container"
    id: "home-page"
    regions:
      event_block: '#event-blocks-region'
      sidebar: '#sidebar-region'

    template: FK.Template('events')
