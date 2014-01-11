class FK.Models.Event extends Backbone.GSModel
  idAttribute: "_id"
  defaults:
    country: 'US'
    name: ''
    user: ''
    description: ''
    #TODO: fix me - all events will start with the date that the file was parsed
    thumbUrl: ''
    mediumUrl: ''
    is_all_day: false
    time_format: ''
    tv_time: ''
    upvotes: 0
    have_i_upvoted: false
    country_full_name: ''

  urlRoot:
    '/events'

  initialize: () =>
    @reminders = new FK.Collections.Reminders()

  is_all_day: () =>
    @.get('is_all_day') is '1' or @.get('is_all_day') is true

  sync: (action, model, options) =>
    methodMap =
      'create': 'POST'
      'update': 'PUT'

    if action == "create" or action == "update"
      httpMethod = methodMap[action]

      xhr = new XMLHttpRequest()
      xhr.open(httpMethod, this.url(), true)
      xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))

      formData = new FormData()

      _.each model.toJSON(), (v, k) ->
        formData.append(k, v)

      xhr.onload = (event) =>
        modelOnServer = JSON.parse event.target.response
        @set modelOnServer
        @trigger 'saved', @

      return xhr.send(formData)

    Backbone.sync(action, model, options)

  parse: (resp) ->
    resp.haveIUpvoted = false if resp.haveIUpvoted is "false"
    resp.is_all_day = false if resp.is_all_day is "false"
    resp

  getters:
    prettyDateTime: () ->
      return "#{@.get('prettyDate')} #{@.get('time')}"

    prettyDate: () ->
      return "" if not @get('datetime')
      return @get('fk_datetime').format('dddd, MMM Do, YYYY')

    time: () ->
      return '' if not @get('datetime')
      return ' – all day' if @.get('is_all_day')

      if @.get('time_format') is 'recurring'
        return @.get('local_time')

      if @.get('time_format') is 'tv_show'
        local_time_split = @.get('local_time').split(':')
        eastern_time = parseInt local_time_split[0]
        eastern_time = eastern_time - 12 if eastern_time > 11

        central_time = parseInt(local_time_split[0]) - 1
        central_time = central_time - 12 if central_time > 11
        central_time = 12 if central_time is 0

        return "#{eastern_time}/#{central_time}c"

      return @.time_from_moment(moment(@.get('datetime')))

    local_hour: ->
      return "" if not @get('local_time')
      local_hour = @get('local_time').split(':')[0]
      local_hour = local_hour - 12 + "" if local_hour > 12
      local_hour

    local_minute: ->
      return "" if not @get('local_time')
      @get('local_time').split(':')[1].split(' ')[0]

    local_ampm: ->
      return "" if not @get('local_time')
      @get('local_time').split(':')[1].split(' ')[1]

    fk_datetime: () ->
      if @.get('time_format') is 'recurring'
        time_split = @.get('time').split(':')
        return moment(@in_my_timezone(@.get('datetime')).format("YYYY-MM-DD")).add(hours: time_split[0], minutes: time_split[1])
      @in_my_timezone(@get('datetime'))

  time_from_moment: (datetime) =>
    @in_my_timezone(datetime).format('h:mm A')

  in_my_timezone: (datetime) ->
    datetime.zone(moment().zone())

  setters:
    datetime: (moment_val) ->
      moment_val = moment(moment_val)
      @.set('local_time', moment_val.format('h:mm A'))
      # set the input time to UTC:
      return moment(moment_val).zone(0)

  upvotes: =>
    @get 'upvotes'

  userHasUpvoted: =>
    @get 'have_i_upvoted'

  toggleUserUpvoted: =>
    @set 'have_i_upvoted', not @userHasUpvoted()

  upvoteToggle: =>
    return if ! @get 'upvote_allowed'
    if @userHasUpvoted()
      @set 'upvotes', @upvotes() - 1
    else
      @set 'upvotes', @upvotes() + 1
    @toggleUserUpvoted()
    @save()

  clearImage: ->
    @unset 'url'
    @unset 'crop_x'
    @unset 'crop_y'
    @unset 'width'
    @unset 'height'
    @unset 'image'

  addReminder: (timeToEvent) ->
    reminder = new FK.Models.Reminder
      user: @get('current_user')
      time_to_event: timeToEvent
      event: @get('_id')
    @reminders.add reminder
    reminder

  removeReminder: (timeToEvent) ->
    @reminders.removeReminder @get('current_user'), timeToEvent, @get('_id')

  reminderTimes: () ->
    @reminders.times()

  editAllowed: (username) ->
    username = @get('current_user') if not username
    @get('user') is '' || @get('user') == username

class FK.Models.EventBlock extends Backbone.Model
  defaults:
    date: moment()
    moreEventsAvailable: true
    event_limit: 3

  initialize: () =>
    @events = new Backbone.Collection()

  isToday: () =>
    @isDate(moment())

  isDate: (date) =>
    date.diff(@get('date'), 'days') == 0

  fetchMore: (howManyMoreEvents, events) =>
    newEventsPromise = events.getEventsByDate(@get('date'), howManyMoreEvents, @events.length)
    newEventsPromise.done( (events) =>
      @addEvents events
      if (events.length < howManyMoreEvents)
        @set('more_events_available', false)
    )

  addEvents: (events) =>
    events = [events] if not _.isArray(events)
    howManyOver = events.length + @events.length - @get('event_limit')
    events = _.take(events, events.length - howManyOver) if howManyOver > 0
    @events.add(events)

  increaseLimit: (howMuch) =>
    @set('event_limit', @get('event_limit') + howMuch)

class FK.Collections.EventList extends Backbone.Collection
  model: FK.Models.Event
  url:
    "/events/"

  fetchStartupEvents: (howManyTopRanked, howManyEventsPerDay, howManyEventsMinimum) =>
    @fetch
      url: 'api' + @url + 'startupEvents'
      data:
        howManyTopRanked: howManyTopRanked
        howManyEventsPerDay: howManyEventsPerDay
        howManyEventsMinimum: howManyEventsMinimum

  fetchMoreEventsByDate: (date, howManyEvents, skip) =>
    @fetch
      url: 'api' + @url + 'eventsByDate'
      remove: false
      data:
        date: moment(date).format('YYYY-MM-DD')
        howManyEvents: howManyEvents
        skip: skip

  getEventsByDate: (date, howManyEvents, skip) =>
    matchingEvents = @chain().
    filter( (event) => event.get('datetime').diff(date, 'days') == 0).
    tail(skip).
    head(howManyEvents).
    value()

    deferred = $.Deferred()

    howManyShort = howManyEvents - matchingEvents.length
    if howManyShort > 0
      @fetchMoreEventsByDate(date, howManyShort, skip).done( (events) =>
        events = _.map(events, (event) => new FK.Models.Event event)
        deferred.resolve(matchingEvents.concat(events))
      )
    else
      deferred.resolve(matchingEvents)

    deferred.promise()

  topRanked: (howManyEvents) =>
    this.chain().
    sortBy( (event) -> event.get('datetime').unix() ).
    sortBy( (event) -> - event.upvotes()).
    first(howManyEvents).
    value()

  topRankedProxy: (howManyEvents) =>
    proxy = new Backbone.Collection @topRanked(howManyEvents)
    @on 'change:upvotes', () => proxy.reset @topRanked(howManyEvents)
    @on 'add', () => proxy.reset @topRanked(howManyEvents)
    proxy

  mostDiscussed: =>
    #TODO: fix me
    @last()

  asBlocks: =>
    blocks = @chain().
    sortBy( (event) -> - event.upvotes()).
    sortBy( (event) -> event.get('datetime').unix() ).
    groupBy( (event) -> event.get('fk_datetime') ).
    map( (events, date) ->
      block = new FK.Models.EventBlock
        date: date
      block.addEvents events
      return block
    ).
    value()
    
    new FK.Collections.EventBlockList blocks

class FK.Collections.EventBlockList extends Backbone.Collection
  model: FK.Models.EventBlock

  addEventsToBlock: (date, events) =>
    block = @find( (blocks) => blocks.isDate(date))
    if not block
      block = new FK.Models.EventBlock
        date: date.toDate()
      @add block
    block.addEvents events
