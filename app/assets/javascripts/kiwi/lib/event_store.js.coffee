class FK.EventStore extends Marionette.Controller
  initialize: (options) =>
    options.events = [] if options.events is null
    @events = new FK.Collections.EventList()
    @blocks = new FK.Collections.EventBlockList()
    @topRanked = new FK.Collections.TopRankedEventList()

    @howManyDaysInBlocks = 3
    @country = 'US'
    @subkasts = _.keys(FK.Data.subkastOptions)

    @country = options.country if options.country
    @subkasts = options.subkasts if options.subkasts

    @vent = options.vent

    @listenTo @events, 'sync', @resetTopRanked
    @listenTo @events, 'add', @addEventToBlock
    @listenTo @blocks, 'change:event_limit', @loadNextEventsForBlock

    @listenTo @vent, 'filter:country', @filterByCountry
    @listenTo @vent, 'filter:subkasts', @filterBySubkasts

    @events.add options.events

  fetchStartupEvents: () =>
    @events.fetchStartupEvents(@country, @subkasts, 10, 5, 12)

  loadNextEvents: (howManyMoreEvents) =>
    date = @blocks.last().relativeDate().add('days', 1)
    @events.fetchMoreEventsAfterDate(date, @country, @subkasts, howManyMoreEvents)

  loadNextEventsForBlock: (block, newLimit) =>
    howManyMoreEvents = newLimit - block.events.length
    date = block.relativeDate()
    events = @events.eventsByDate(date, @country, @subkasts, howManyMoreEvents, block.events.models)

    _.each(events, @addEventToBlock)

    @events.fetchMoreEventsByDate(
      date,
      @country,
      @subkasts,
      howManyMoreEvents,
      block.events.length
    )

  resetTopRanked: () =>
    @topRanked.reset @events.topRanked(10, moment().startOf('day'), moment().add('days', 6).endOf('day'), @country, @subkasts)

  addEventToBlock: (event) =>
    return if (event.get('country') isnt @country and event.get('location_type') is 'national')
    return if (not _.contains(@subkasts, event.get('subkast')))
    @blocks.addEventToBlock moment(event.get('fk_datetime').startOf('day')), @country, @subkasts, event, @events

  filterByCountry: (country) =>
    @country = country
    @refresh()

  filterBySubkasts: (subkasts) =>
    @subkasts = subkasts
    @refresh()

  getSingleSubkast: () =>
    if @subkasts.length == 1
      return @subkasts[0]
    else
      return false

  refresh: () =>
    @events.reset()
    @topRanked.reset()
    @blocks.reset()
    @fetchStartupEvents()
