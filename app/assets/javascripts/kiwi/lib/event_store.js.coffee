class FK.EventStore extends Marionette.Controller
  initialize: (options) =>
    options.events = [] if options.events is null
    @events = new FK.Collections.EventList()
    @blocks = new FK.Collections.EventBlockList()
    @topRanked = new FK.Collections.BaseEventList()

    @howManyDaysInBlocks = 3
    @country = 'CA'
    @subkasts = _.keys(FK.Data.subkastOptions)

    @listenTo @events, 'sync', @resetTopRanked
    @listenToOnce @events, 'sync', @startAddListeners
    @listenTo @events, 'add', @addEventToBlock
    @listenTo @blocks, 'change:event_limit', @loadNextEventsForBlock

    @events.add options.events

  fetchStartupEvents: () =>
    @events.fetchStartupEvents(10, 3, 12)

  startAddListeners: () =>
    @listenTo @events, 'add', @resetTopRanked

  loadNextEvents: (howManyMoreEvents) =>
    date = @blocks.last().relativeDate().add('days', 1)
    @events.fetchMoreEventsAfterDate(date, howManyMoreEvents)

  loadNextEventsForBlock: (block, newLimit) =>
    howManyMoreEvents = newLimit - block.events.length
    date = block.relativeDate()
    events = @events.eventsByDate(date, howManyMoreEvents, block.events.models)

    _.each(events, @addEventToBlock)

    if events.length < howManyMoreEvents
      @events.fetchMoreEventsByDate(
        date,
        howManyMoreEvents - events.length,
        block.events.length + events.length
      ).done ( () =>
        block.checkLimit()
      )

  resetTopRanked: () =>
    @topRanked.reset @events.topRanked(10, moment().startOf('day'), moment().add('days', 6).endOf('day'), @country, @subkasts)

  addEventToBlock: (event) =>
    return if (event.get('country') isnt @country and event.get('location_type') is 'national')
    return if (not _.contains(@subkasts, event.get('subkast')))
    @blocks.addEventToBlock moment(event.get('fk_datetime').format('YYYY-MM-DD')), event

  filterByCountry: (country) =>
    @country = country
    @refresh()

  filterBySubkasts: (subkasts) =>
    @subkasts = subkasts
    @refresh()

  refresh: () =>
    @resetTopRanked()
    @blocks.reset()
    @events.each @addEventToBlock
