class FK.EventStore extends Marionette.Controller
  initialize: (options) =>
    options.events = [] if options.events is null
    @events = new FK.Collections.EventList()
    @blocks = new FK.Collections.EventBlockList()
    @topRanked = new FK.Collections.BaseEventList()

    @howManyDaysInBlocks = 3

    @listenTo @events, 'sync', @resetTopRanked
    @listenToOnce @events, 'sync', @startAddListeners
    @listenTo @events, 'add', @addEventToBlock

    @events.add options.events

  fetchStartupEvents: () =>
    @events.fetchStartupEvents(10, 3, 12)

  startAddListeners: () =>
    @listenTo @events, 'add', @resetTopRanked

  moreBlocks: (howManyMoreEvents) =>
    nextDay = @blocks.last().events.last().get('datetime').clone().add('days', 1)
    @events.fetchMoreEventsAfterDate(nextDay, howManyMoreEvents)

  resetTopRanked: () =>
    @topRanked.reset @events.topRanked(10, moment(), moment().add('days', 7))

  addEventToBlock: (event) =>
    @blocks.addEventToBlock moment(event.get('fk_datetime').format('YYYY-MM-DD')), event
