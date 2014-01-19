class FK.EventStore extends Marionette.Controller
  initialize: (options) =>
    options.events = [] if options.events is null
    @events = new FK.Collections.EventList options.events
    @blocks = new FK.Collections.EventBlockList()
    @topRanked = new FK.Collections.BaseEventList()

    @howManyDaysInBlocks = 3

    @listenToOnce @events, 'sync', @resetBlocks
    @listenTo @events, 'sync', @resetTopRanked
    @listenToOnce @events, 'sync', @startAddListeners

  fetchStartupEvents: () =>
    @events.fetchStartupEvents(10, 3, 12)

  startAddListeners: () =>
    @listenTo @events, 'add', @resetTopRanked

  resetBlocks: () =>
    @blocks.reset @events.asBlocks()

  moreBlocks: (howManyMoreEvents) =>
    nextDay = @blocks.last().events.last().get('datetime').clone().add('days', 1)
    @events.getBlocksAfterDate(nextDay, howManyMoreEvents).done (blocks) =>
      @blocks.add blocks
      @howManyBlocks = @blocks.length

  resetTopRanked: () =>
    @topRanked.reset @events.topRanked(10, moment(), moment().add('days', 7))
