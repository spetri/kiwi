class FK.EventStore extends Marionette.Controller
  initialize: (startupEvents) =>
    @events = new FK.Collections.EventList startupEvents
    @blocks = new FK.Collections.EventBlockList()
    @topRankedEvents = new FK.Collections.BaseEventList()

    @howManyDaysInBlocks = 3

    @listenToOnce @events, 'sync', @resetBlocks

    @events.fetchStartupEvents(10, 3, 10)

  resetBlocks: () =>
    blocks = _.take(@events.asBlocks(), @howManyDaysInBlocks)
    @blocks.reset blocks

  addBlocks: (howManyBlocks) =>
    @howManyDaysInBlocks += howManyBlocks
    howManyBlocksAlready = @blocks.length
    blocks = _.chain(@events.asBlocks()).
      drop(howManyBlocksAlready).
      take(@howManyDaysInBlocks).
      value()
    @blocks.add blocks
