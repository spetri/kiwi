class FK.EventStore extends Marionette.Controller
  initialize: (startupEvents = []) =>
    @events = new FK.Collections.EventList startupEvents
    @blocks = new FK.Collections.EventBlockList()
    @topRanked = new FK.Collections.BaseEventList()

    @howManyDaysInBlocks = 3
    @howManyBlocks = 3

    @listenToOnce @events, 'sync', @resetBlocks
    @listenTo @events, 'sync', @resetTopRanked
    @listenToOnce @events, 'sync', @startAddListeners

  fetchStartupEvents: () =>
    @events.fetchStartupEvents(10, 3, 10)

  startAddListeners: () =>
    @listenTo @events, 'add', @resetTopRanked

  resetBlocks: () =>
    blocks = _.take(@events.asBlocks(), @howManyDaysInBlocks)
    @blocks.reset blocks

  moreBlocks: (howManyBlocks) =>
    howManyBlocksAlready = @blocks.length
    blocks = _.chain(@events.asBlocks()).
      drop(howManyBlocksAlready).
      take(howManyBlocks).
      value()
    @blocks.add blocks

    if @blocks.length < @howManyBlocks + howManyBlocks
      @events.getBlocksAfterDate(@blocks.last().get('date').clone().add('days', 1), @howManyBlocks - @blocks.length).done (blocks) =>
        @blocks.add blocks
        @howManyBlocks = @blocks.length
    else
      @howManyBlocks = @blocks.length

  resetTopRanked: () =>
    @topRanked.reset @events.topRanked(10, moment(), moment().add('days', 7))
