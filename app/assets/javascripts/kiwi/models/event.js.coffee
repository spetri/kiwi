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

  fetchComments: () =>
    @comments.fetchForEvent(@)
    return @comments

  initialize: () =>
    @reminders = new FK.Collections.Reminders()
    @comments  = new FK.Collections.Comments()
    #Backbone thing: when collection fetches from another url, models are
    #forced to have that url, undo that here
    #TODO: Report backbone bug?
    @url = Backbone.Model.prototype.url

    @on 'change:time_format', @update_tv_time

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

  validate: (attrs, options) =>
    errors = []

    errors.push({field: 'name', message: 'Event must have a name.'}) if not attrs.name
    errors.push({field: 'name', message: 'Event name must be less than 100 characters long.'}) if attrs.name and attrs.name.length > 100

    errors.push({field: 'datetime', message: 'Event must have a datetime.'}) if not attrs.datetime

    errors.push({field: 'subkast', message: 'Event must have a subkast.'}) if not _.contains(FK.App.request('subkastKeys'), attrs.subkast)

    if errors.length == 0 then false else errors

  groupedErrors: () =>
    errors = {}
    _.each(@validationError, (error) =>
      errors[error.field] = [] if not errors[error.field]
      errors[error.field].push error.message
    )

    errors

  isAllDay: () =>
    @get('is_all_day') is '1' or @get('is_all_day') is true or @get('is_all_day') is 'true'

  inFuture: () =>
    against = moment()
    against.startOf('day') if @isAllDay()
    (@get('fk_datetime').diff(against, 'seconds')) >= 0

  isOnDate: (date) =>
    @get('fk_datetime').diff(date, 'days') == 0 && date.date() == @get('fk_datetime').date()

  getters:
    fk_datetime: () ->
      return @datetimeRecurring() if @get('time_format') is 'recurring'
      return @datetimeTV() if @get('time_format') is 'tv_show'
      return @datetimeAllDay() if @isAllDay()
      return @datetimeNormal()

    time: () ->
      @get('timeAsString')

    timeAsString: () ->
      return '' unless @get('datetime')
      return 'All Day' if @isAllDay()

      datetime = @get('fk_datetime')

      if @get('time_format') is 'tv_show'
        date_parsed = moment(@get('local_date'))
        eastern_time = moment("#{@get('local_time')} #{date_parsed.format('YYYY-MM-DD')}", 'h:mm A YYYY-MM-DD')
        central_time = parseInt(eastern_time.format('h')) - 1
        central_time = 12 if central_time is 0

        minutes = eastern_time.format('mm')
        return "#{eastern_time.format('h')}:#{minutes}/#{central_time}:#{minutes}c"
      else
        return @time_from_moment(datetime)

    dateAsString: () ->
      return "" unless @get('datetime')
      return @get('fk_datetime').format('dddd, MMM Do, YYYY')

    datetimeAsString: () ->
      return "#{@.get('dateAsString')}, #{@.get('timeAsString')}"

    local_hour: ->
      return "" unless @get('local_time')
      return "" if @get('local_time').indexOf(':') is  -1
      local_hour = @get('local_time').split(':')[0]
      local_hour = local_hour - 12 + "" if local_hour > 12
      local_hour

    local_minute: ->
      return "" unless @get('local_time')
      return "" if @get('local_time').indexOf(':') is  -1
      @get('local_time').split(':')[1].split(' ')[0]

    local_ampm: ->
      return "" unless @get('local_time')
      return "" if @get('local_time').indexOf(':') is  -1
      @get('local_time').split(':')[1].split(' ')[1]

  datetimeNormal: () ->
    return moment() unless @get('datetime')
    @in_my_timezone(@get('datetime')).clone()

  datetimeRecurring: () ->
    recurringHours = parseInt @get('local_hour')
    recurringMinutes = parseInt @get('local_minute')

    recurringHours += 12 if @get('local_ampm') is 'PM' and recurringHours != 12
    @in_my_timezone(@get('datetime')).startOf('day').clone().
    add( hours: recurringHours, minutes: recurringMinutes )

  datetimeTV: () ->
    easternHours = parseInt @get('local_hour')
    easternMinutes = parseInt @get('local_minute')

    easternHours += 12 if @get('local_ampm') is 'PM' && easternHours != 12
    zone = ' -0' + (FK.App.request('easternOffset') / 60) + '00'
    moment(moment(@get('local_date')).format('YYYY-MM-DD') + zone, 'YYYY-MM-DD ZZ').
    add( hours: easternHours, minutes: easternMinutes )

  datetimeAllDay: () =>
    moment(moment(@get('local_date')).format('YYYY-MM-DD'))

  time_from_moment: (datetime) =>
    @in_my_timezone(datetime).format('h:mm A')

  in_my_timezone: (datetime) ->
    datetime.clone().zone(moment().zone())

  in_range: (startDate, endDate) ->
    if @get('is_all_day')
      @get('fk_datetime').diff(startDate, 'days') >= 0 and @get('fk_datetime').diff(endDate, 'days') <= 0
    else
      @get('fk_datetime').diff(startDate, 'seconds') >= 0 and @get('fk_datetime').diff(endDate, 'seconds') < 0

  moveToDateTime: (date, time) =>
    @set('local_time', time)
    @set('local_date', moment(date))
    @set('datetime', moment("#{date} #{time}"))

  setters:
    datetime: (moment_val) ->
      return unless moment_val
      moment_val = moment(moment_val)
      if @get('time_format') is 'tv_show'
        moment_val = moment(moment_val.format('YYYY-MM-DD') + ' ' + moment_val.format('h:mm A') + ' EST')

      # set the input time to UTC:
      adjustedMoment = moment(moment_val).zone(0)
      return adjustedMoment

    update_tv_time: (model, format) ->
      if @has('datetime') and format is 'tv_show'
        @set('datetime', moment(@get('local_date') + ' ' + @get('local_time')))

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

  initialUpvote: =>
    @set 'upvotes', 1
    @set 'have_i_upvoted', true

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

  fullSubkastName: =>
    return 'Other' if not @has('subkast')
    return FK.Data.subkastOptions[@get('subkast')]

  descriptionParsed: () =>
    marked(@get('description'))

class FK.Models.EventBlock extends Backbone.Model
  defaults: () =>
    return {
      date: moment()
      more_events_available: true
      event_limit: 5
    }

  initialize: (options) =>
    @events = new FK.Collections.BaseEventList()
    @on 'change:event_max_count', @determineMoreEventsAvailable
    @events.on 'add', @determineMoreEventsAvailable
    @events.on 'remove reset', @checkEventCount

  observeEvents: (events) =>
    @allEvents = events
    @checkEventCount()

  isToday: () =>
    @isDate(moment())

  isDate: (date) =>
    date.diff(@get('date'), 'days') == 0 && date.date() == @get('date').date()

  addEvents: (events) =>
    events = [events] if not _.isArray(events)
    howManyOver = events.length + @events.length - @get('event_limit')
    events = _.take(events, events.length - howManyOver) if howManyOver > 0
    @events.add(events)

  checkLimit: () =>
    @set({event_limit: @events.length}, {silent: true}) if @events.length < @get('event_limit')

  increaseLimit: (howMuch) =>
    @set('event_limit', @get('event_limit') + howMuch)

  determineMoreEventsAvailable: =>
    return @destroy() if @get('event_max_count') == 0 && @allEvents
    visible_events = @events.length # because this is a backbone only viewmodel
    if @get('event_max_count') is undefined
      @set('more_events_available', false)
    else
      @set('more_events_available', visible_events < @get('event_max_count'))

  relativeDate: () =>
    moment(@get('date'))

  checkEventCount: =>
    return @set('event_max_count', 0) if not @allEvents
    events = @allEvents.eventsByDate(
      @relativeDate(),
      @get('country'),
      @get('subkasts')
    )
    @set('event_max_count', events.length )

class FK.Collections.BaseEventList extends Backbone.Collection
  model: FK.Models.Event
  comparator: (event1, event2) =>
    return -1 if event1.upvotes() > event2.upvotes()
    return 0 if event1.upvotes() == event2.upvotes()
    return 1 if event1.upvotes() < event2.upvotes()


class FK.Collections.TopRankedEventList extends FK.Collections.BaseEventList
  comparator: (event1, event2) =>
    return -1 if event1.upvotes() > event2.upvotes()
    if event1.upvotes() == event2.upvotes()

      return 1 if not event2.has('datetime')
      return -1 if not event1.has('datetime')

      return 1 if event1.get('fk_datetime').diff(event2.get('fk_datetime'), 'seconds') > 0
      return 0 if event1.get('fk_datetime').diff(event2.get('fk_datetime'), 'seconds') == 0
      return -1 if event1.get('fk_datetime').diff(event2.get('fk_datetime'), 'seconds') < 0

    return 1 if event1.upvotes() < event2.upvotes()

class FK.Collections.EventList extends FK.Collections.BaseEventList
  url:
    "/events/"

  fetchStartupEvents: (country, subkasts, howManyTopRanked, howManyEventsPerDay, howManyEventsMinimum) =>
    @fetch
      url: 'api' + @url + 'startupEvents'
      data:
        datetime: moment().startOf('day').add('minutes', moment().zone()).format('YYYY-MM-DD HH:mm:ss')
        zone_offset: moment().zone()
        country: country
        subkasts: subkasts
        howManyTopRanked: howManyTopRanked
        howManyEventsPerDay: howManyEventsPerDay
        howManyEventsMinimum: howManyEventsMinimum

  fetchMoreEventsByDate: (date, country, subkasts, howManyEvents, skip) =>
    @fetch
      url: 'api' + @url + 'eventsByDate'
      remove: false
      data:
        datetime: moment(date).format('YYYY-MM-DD HH:mm:SS')
        zone_offset: moment().zone()
        country: country
        subkasts: subkasts
        howManyEvents: howManyEvents
        skip: skip

  fetchMoreEventsAfterDate: (date, country, subkasts, howManyEvents) =>
    @fetch
      url: 'api' + @url + 'eventsAfterDate'
      remove: false
      data:
        datetime: moment(date).format('YYYY-MM-DD HH:mm:SS')
        zone_offset: moment().zone()
        country: country
        subkasts: subkasts
        howManyEvents: howManyEvents

  allEventsByDate: (date, country, subkasts, skip = []) =>
    @chain().
    filter( (event) -> event.isOnDate(date) ).
    filter( (event) -> event.get('location_type') is 'international' or event.get('country') == country ).
    filter( (event) -> _.contains(subkasts, event.get('subkast')) ).
    reject( (event) -> _.contains(_.map(skip, (event) -> event.get('_id')), event.get('_id')) ).
    value()

  eventsByDate: (date, country, subkasts, howManyEvents = 9999999, skip = []) =>
    _.chain(@allEventsByDate(date, country, subkasts, skip)).
    first(howManyEvents).
    value()

  topRanked: (howManyEvents, startDate, endDate, country, subkasts) =>
    @chain().
    filter( (event) => event.in_range(startDate, endDate)).
    filter( (event) => event.get('location_type') is 'international' or event.get('country') == country ).
    filter( (event) => _.contains(subkasts, event.get('subkast') )).
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

  addEventToBlock: (date, country, subkasts, event, events) =>
    return if not (event.inFuture() or event.isOnDate(moment()))
    block = @find( (block) => block.isDate(date))
    if not block
      block = new FK.Models.EventBlock
        date: moment(date)
        country: country
        subkasts: _.clone(subkasts)
      block.observeEvents events
      @add block
    block.addEvents event
