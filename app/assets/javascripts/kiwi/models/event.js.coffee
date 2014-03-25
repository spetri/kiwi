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

    errors.push('Event must have a name.') if not attrs.name
    errors.push('Event name must be less than 100 characters long.') if attrs.name and attrs.name.length > 100

    errors.push('Event must have a datetime.') if not attrs.datetime

    errors.push('Event must have a real subkast.') if not _.contains(FK.App.request('subkastKeys'), attrs.subkast)

    if errors.length == 0 then false else errors

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
      return '' if not @get('datetime')
      return 'All Day' if @isAllDay()

      datetime = @get('fk_datetime')

      if @get('time_format') is 'tv_show'
        eastern_time = datetime.format('h')

        central_time = parseInt(datetime.format('h')) - 1
        central_time = 12 if central_time is 0

        minutes = datetime.format('mm')

        return "#{eastern_time}:#{minutes}/#{central_time}:#{minutes}c"

      else
        return @time_from_moment(datetime)

    dateAsString: () ->
      return "" if not @get('datetime')
      return @get('fk_datetime').format('dddd, MMM Do, YYYY')

    datetimeAsString: () ->
      return "#{@.get('dateAsString')}, #{@.get('timeAsString')}"

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

  datetimeNormal: () ->
    @in_my_timezone(@get('datetime')).clone()

  datetimeRecurring: () ->
    recurringHours = parseInt @get('local_hour')
    recurringMinutes = parseInt @get('local_minute')

    recurringHours += 12 if @get('local_ampm') is 'PM'

    @in_my_timezone(@get('datetime')).startOf('day').clone().
    add( hours: recurringHours, minutes: recurringMinutes )

  datetimeTV: () ->
    easternHours = parseInt @get('local_hour')
    easternMinutes = parseInt @get('local_minute')

    easternHours += 12 if @get('local_ampm') is 'PM'

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

  setters:
    datetime: (moment_val) ->
      moment_val = moment(moment_val)
      @set('local_time', moment_val.format('h:mm A'))
      @set('local_date', moment_val.format('YYYY-MM-DD'))
      moment_val.zone(FK.App.request('easternOffset')) if @get('time_format') is 'tv_show'
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
    @get('description').replace(new RegExp("(http:\/\/)?(([a-zA-Z]+\\.)?[a-zA-Z]+\\.[a-zA-Z]{2,3}(\/[a-zA-Z\/_]+(\\.[a-zA-Z]+)?)?)", "g"), (m1) =>
      m2 = ''
      m2 = 'http://' if m1.indexOf('http') != 0
      "<a target=\"_blank\" href=\"#{m2}#{m1}\">#{m1}</a>"
    )

class FK.Models.EventBlock extends Backbone.Model
  defaults: () =>
    return {
      date: moment()
      more_events_available: true
      event_limit: 5
    }

  initialize: () =>
    @events = new FK.Collections.BaseEventList()
    @on 'change:event_max_count', @determineMoreEventsAvailable
    @events.on 'add remove reset', @determineMoreEventsAvailable
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
    @set('more_events_available', @events.length < @get('event_max_count'))

  relativeDate: () =>
    moment(@get('date').clone().add({ minutes: moment().zone() }))

  checkEventCount: =>
    $.get(
      '/api/events/countByDate',
      datetime: @relativeDate().format('YYYY-MM-DD HH:mm:ss'),
      zone_offset: moment().zone()
      country: @get('country')
      subkasts: @get('subkasts')
      (resp) =>
        @set('event_max_count', resp.count)
    )

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

  eventsByDate: (date, country, subkasts, howManyEvents, skip = []) =>
    @chain().
    filter( (event) -> event.isOnDate(date) ).
    filter( (event) -> event.get('location_type') is 'international' or event.get('country') == country ).
    filter( (event) -> _.contains(subkasts, event.get('subkast')) ).
    reject( (event) -> _.contains(_.map(skip, (event) -> event.get('_id')), event.get('_id')) ).
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

  addEventToBlock: (date, country, subkasts, event) =>
    return if not (event.inFuture() or event.isOnDate(moment()))
    block = @find( (block) => block.isDate(date))
    if not block
      block = new FK.Models.EventBlock
        date: moment(date)
        country: country
        subkasts: _.clone(subkasts)
      @add block
    block.addEvents event
