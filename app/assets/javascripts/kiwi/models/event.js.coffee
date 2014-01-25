class FK.Models.Event extends Backbone.GSModel
  idAttribute: "_id"
  defaults: () =>
    return {
      location_type: 'international'
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
    }

  urlRoot: () =>
    '/events'

  initialize: () =>
    @reminders = new FK.Collections.Reminders()
    #Backbone thing: when collection fetches from another url, models are
    #forced to have that url, undo that here
    #TODO: Report backbone bug?
    @url = Backbone.Model.prototype.url

  is_all_day: () =>
    @.get('is_all_day') is '1' or @.get('is_all_day') is true

  inFuture: () =>
    @get('fk_datetime').diff(moment(), 'seconds') > 0

  isOnDate: (date) =>
    @get('fk_datetime').diff(date, 'days') == 0 && date.date() == @get('fk_datetime').date()

  sync: (action, model, options) =>
    methodMap =
      'create': 'POST'
      'update': 'PUT'

    if action == "create" or action == "update"
      httpMethod = methodMap[action]

      xhr = new XMLHttpRequest()
      xhr.open(httpMethod, @url(), true)
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
    resp.is_all_day = false if resp.is_all_day is "false" || resp.is_all_day is "undefined"
    resp

  getters:
    prettyDateTime: () ->
      return "#{@.get('prettyDate')} #{@.get('time')}"

    prettyDate: () ->
      return "" if not @get('datetime')
      return @get('fk_datetime').format('dddd, MMM Do, YYYY')

    time: () ->
      return '' if not @get('datetime')
      return ' - all day ' if @is_all_day()

      if @.get('time_format') is 'recurring'
        return @.get('local_time')

      if @.get('time_format') is 'tv_show'
        eastern_time = parseInt @get('local_hour')

        central_time = parseInt(@get('local_hour')) - 1
        central_time = 12 if central_time is 0

        minutes = @get('local_minute')

        return "#{eastern_time}:#{minutes}/#{central_time}:#{minutes}c"

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
        event_time = moment(@get('local_time'), 'h:mm A')
        return moment(
              @in_my_timezone(@.get('datetime')).format("YYYY-MM-DD")
            ).
            add(
              hours: event_time.hour(), minutes: event_time.minute()
            )
      @in_my_timezone(@get('datetime')).clone()

  time_from_moment: (datetime) =>
    @in_my_timezone(datetime).format('h:mm A')

  in_my_timezone: (datetime) ->
    datetime.clone().zone(moment().zone())

  in_range: (startDate, endDate) ->
    if @get('is_all_day')
      @get('fk_datetime').diff(startDate, 'days') >= 0 and @get('fk_datetime').diff(endDate, 'days') <= 0
    else
      @get('fk_datetime').diff(startDate, 'seconds') >= 0 and @get('fk_datetime').diff(endDate, 'seconds') < 0

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
  defaults: () =>
    return {
      date: moment()
      more_events_available: true
      event_limit: 3
    }

  initialize: () =>
    @events = new FK.Collections.BaseEventList()
    @on 'change:event_max_count', @determineMoreEventsAvailable
    @events.on 'add remove reset', @determineMoreEventsAvailable

  isToday: () =>
    @isDate(moment())

  isDate: (date) =>
    date.diff(@get('date'), 'days') == 0 && date.date() == @get('date').date()

  addEvents: (events) =>
    events = [events] if not _.isArray(events)

    howManyOver = events.length + @events.length - @get('event_limit')

    events = _.take(events, events.length - howManyOver) if howManyOver > 0

    @events.add(events)

    if @events.length < @get('event_limit')
      @set('more_events_available', false)
    else
      @set('more_events_available', true)

  checkLimit: () =>
    @set({event_limit: @events.length}, {silent: true}) if @events.length < @get('event_limit')

  increaseLimit: (howMuch) =>
    @set('event_limit', @get('event_limit') + howMuch)

  determineMoreEventsAvailable: =>
    @set('more_events_available', @events.length < @get('event_max_count'))

  checkEventCount: =>
    $.get(
      '/api/events/countByDate',
      date: @get('date').format('YYYY-MM-DD HH:MM:SS'),
      (resp) =>
        @set('event_max_count', resp.count)
    )

class FK.Collections.BaseEventList extends Backbone.Collection
  model: FK.Models.Event
  comparator: (event1, event2) =>
    return -1 if event1.upvotes() > event2.upvotes()
    if event1.upvotes() == event2.upvotes()
      return 1 if event1.get('datetime') > event2.get('datetime')
      return 0 if event1.get('datetime') == event2.get('datetime')
      return -1 if event1.get('datetime') < event2.get('datetime')
    return 1 if event1.upvotes() < event2.upvotes()

class FK.Collections.EventList extends FK.Collections.BaseEventList
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
        datetime: moment(date).format('YYYY-MM-DD HH:MM:SS')
        howManyEvents: howManyEvents
        skip: skip

  fetchMoreEventsAfterDate: (date, howManyEvents) =>
    @fetch
      url: 'api' + @url + 'eventsAfterDate'
      remove: false
      data:
        datetime: moment(date).format('YYYY-MM-DD HH:MM:SS')
        howManyEvents: howManyEvents

  eventsByDate: (date, howManyEvents, skip = []) =>
    @chain().
    filter( (event) -> event.isOnDate(date) ).
    reject( (event) -> _.contains(_.map(skip, (event) -> event.get('_id')), event.get('_id')) ).
    first(howManyEvents).
    value()

  topRanked: (howManyEvents, startDate, endDate) =>
    @chain().
    filter( (event) => event.in_range(startDate, endDate)).
    first(howManyEvents).
    value()

class FK.Collections.EventBlockList extends Backbone.Collection
  model: FK.Models.EventBlock
  comparator: (block1, block2) =>
    date1 = block1.get('date')
    date2 = block2.get('date')
    return 1 if date1 > date2
    return 0 if date1 == date2
    return -1 if date1 < date2

  addEventToBlock: (date, event) =>
    block = @find( (block) => block.isDate(date))
    if not block
      block = new FK.Models.EventBlock
        date: moment(date)
      @add block
    block.addEvents event
