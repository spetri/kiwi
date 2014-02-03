# use require to load any .js file available to the asset pipeline
#= require application

describe "Event", ->
  loadFixtures 'event_fixture' # located at 'spec/javascripts/fixtures/event_fixture.html.erb'
  it "Default country to be US", ->
    v = new FK.Models.Event()
    expect(v.get('country')).toEqual('US')

  describe "date and time", ->
    beforeEach ->
      @event = new FK.Models.Event()

    describe "normal datetime", ->
      describe "in the future", ->
        beforeEach ->
          @event.set( datetime: moment().add(minutes: 1) )

        it "should be in the future", ->
          expect(@event.inFuture()).toBeTruthy()

        it "should be on the current date", ->
          expect(@event.isOnDate(moment())).toBeTruthy()

        it "should provide the correct datetime date", ->
          expect(@event.get('fk_datetime').format('YYYY-MM-DD')).toBe(moment().clone().add(minutes: 1).format('YYYY-MM-DD'))

        it "should provide the correct datetime time", ->
          expect(@event.get('fk_datetime').format('HH:mm:SS')).toBe(moment().clone().add(minutes: 1).format('HH:mm:SS'))

        it "should provide the date in the forekast format", ->
          expect(@event.get('dateAsString')).toEqual('Thursday, Jan 16th, 2014')

        it "should provide the time in the forekast format", ->
          expect(@event.get('timeAsString')).toEqual('12:01 PM')

      describe "in the past", ->
        beforeEach ->
          @event.set( datetime: moment().add(minutes : -1))

        it "should not be in the future", ->
          expect(@event.inFuture()).toBeFalsy()

        it "should provide the correct datetime time", ->
          expect(@event.get('fk_datetime').format('HH:mm:SS')).toBe(moment().add(minutes: -1).format('HH:mm:SS'))

        it "should provide the correct time in the forekast format", ->
          expect(@event.get('timeAsString')).toEqual('11:59 AM')

      describe "days in the future", ->
        beforeEach ->
          @event.set( datetime: moment().add(days: 3))

        it "should be in the future", ->
          expect(@event.inFuture()).toBeTruthy()

        it "should be on the date in the future", ->
          expect(@event.isOnDate(moment().add(days: 3))).toBeTruthy()

        it "should provide the correct datetime date", ->
          expect(@event.get('fk_datetime').format('YYYY-MM-DD')).toBe(moment().add(days: 3).format('YYYY-MM-DD'))

        it "should provide the date in the forekast format", ->
          expect(@event.get('dateAsString')).toEqual('Sunday, Jan 19th, 2014')
          
    describe "all day events", ->
      describe "today", ->
        beforeEach ->
          @event.set (datetime: moment(), is_all_day: true)

        it "should be on today's date", ->
          expect(@event.isOnDate(moment()))

        it "should be in the future", ->
          expect(@event.inFuture()).toBeTruthy()

        it "should have a datetime at the start of today", ->
          expect(@event.get('fk_datetime').format('HH:mm:SS')).toBe('00:00:00')

    it "can create a local time on set", ->
      event = new FK.Models.Event datetime: moment("2013-12-12, 13:00 GMT-500")
      expect(event.get('local_time')).toBe('1:00 PM')

    it "can detect TV times", ->
      v = new FK.Models.Event time_format: 'tv_show', datetime: moment("2013-12-12, 16:30 GMT-500")
      expect(v.get('time')).toEqual('4:30/3:30c')
      
      v = new FK.Models.Event time_format: 'tv_show', datetime: moment("2013-12-12, 1:00 GMT-500")
      expect(v.get('time')).toEqual('1:00/12:00c')
      
      v = new FK.Models.Event time_format: 'tv_show', datetime: moment("2013-12-12, 20:00 GMT+200")
      expect(v.get('time')).toEqual('1:00/12:00c')

    it "can get a datetime in the local timezone without changing it", ->
      v = new FK.Models.Event
        datetime: moment().zone(0)
      expect(v.in_my_timezone(v.get('datetime')).hour()).toBe(moment().hour())
      expect(v.get('datetime').hour()).toBe(moment().zone(0).hour())

    it "can detect if an event is in the future", ->
      event = new FK.Models.Event
        datetime: moment().add('seconds', 10)

      expect(event.inFuture()).toBeTruthy()

    it "can detect if an event with a recurring time format is in the future", ->
      event = new FK.Models.Event
        datetime: moment().toDate()
        local_time: moment().add('hours', 4).format('h:mm A')
        time_format: 'recurring'

      expect(event.inFuture()).toBeTruthy()

  describe "when upvoting", ->
    beforeEach ->
      @event = new FK.Models.Event()
      @event.set 'upvote_allowed', true
      @xhr = sinon.useFakeXMLHttpRequest()

    afterEach ->
      @xhr.restore()

    it "should be able to increase its upvotes", ->
      @event.upvoteToggle()
      expect(@event.upvotes()).toBe(1)

    it "should be able to toggle its upvotes", ->
      @event.upvoteToggle()
      @event.upvoteToggle()
      expect(@event.upvotes()).toBe(0)

  describe "when getting the pieces of the local time", ->
    beforeEach ->
      @event = new FK.Models.Event()
      @event.set('local_time', '7:40 PM')

    it "should be able to get the local hour", ->
      expect(@event.get('local_hour')).toBe('7')

    it "should be able to get the local minutes", ->
      expect(@event.get('local_minute')).toBe('40')

    it "should be able to get the local ampm", ->
      expect(@event.get('local_ampm')).toBe('PM')

    describe "when getting the pieces of a 24hr clock local time", ->
      beforeEach ->
        @event.set('local_time', '19:25 AM')

      it "should be able to get the local hour", ->
        expect(@event.get('local_hour')).toBe('7')

      it "should be able to get the local ampm", ->
        expect(@event.get('local_ampm')).toBe('AM')

  describe "when determining the time range", ->
    it "should be able to place the event in a simple range", ->
      event = new FK.Models.Event (datetime: moment().add('hours', 2))
      expect(event.in_range(moment(), moment().add('hours', 3))).toBeTruthy()

    it "should be able to place the event in a range from the start datetime being the time of the event", ->
      event = new FK.Models.Event (datetime: moment().add('hours', 2))
      expect(event.in_range(moment().add('hours', 2), moment().add('hours', 3))).toBeTruthy()

    it "should be able to place the event in a range when the event is all day", ->
      event = new FK.Models.Event (datetime: moment(), is_all_day: true)
      expect(event.in_range(moment().add('hours', 2), moment().add('hours', 3))).toBeTruthy()
      

  describe "when adding an image", ->
    beforeEach ->
      @event = new FK.Models.Event()
      @event.set 'url', 'http://googlimage.ca'
      @event.set 'crop_x', 24
      @event.set 'crop_y', 25
      @event.set 'width', 200
      @event.set 'height', 300
      @event.set 'image', 'FILE'

    it "should be able to clear all image properties", ->
      @event.clearImage()
      expect(@event.get('url')).not.toBeDefined()
      expect(@event.get('crop_x')).not.toBeDefined()
      expect(@event.get('crop_y')).not.toBeDefined()
      expect(@event.get('width')).not.toBeDefined()
      expect(@event.get('height')).not.toBeDefined()
      expect(@event.get('image')).not.toBeDefined()

  describe 'when working with reminders', ->
    beforeEach ->
      @event = new FK.Models.Event()
      @event.set '_id', '1234asdf'
      @event.set 'current_user', 'grayden'
      @event.addReminder('15m')
    
    it 'should be able to add a reminder', ->
      expect(@event.reminders.length).toBe(1)

    it 'should return the reminder created with the event id on it', ->
      reminder = @event.addReminder('15m')
      expect(reminder.get('user')).toBe('grayden')
      expect(reminder.get('time_to_event')).toBe('15m')
      expect(reminder.get('event')).toBe(@event.id)

    it 'should be able to get a list of the reminder times in the event', ->
      @event.addReminder('1h')
      @event.addReminder('24h')

      expect(@event.reminderTimes()).toEqual(['15m', '1h', '24h'])

    it 'should be able to remove a reminder', ->
      @event.removeReminder '15m'
      expect(@event.reminderTimes().length).toBe(0)

  describe 'authorization', ->
    beforeEach ->
      @event = new FK.Models.Event()

    it 'should be able to authenticate user when the event has no user', ->
      expect(@event.editAllowed('grayden')).toBeTruthy()

    it 'should be able to authenticate user when the event user matches the input user', ->
      @event.set 'user', 'grayden'
      expect(@event.editAllowed('grayden')).toBeTruthy()

    it 'should be able to reject authentication when the event user does not match the input user', ->
      @event.set 'user', 'gsmith'
      expect(@event.editAllowed('grayden')).toBeFalsy()

    it 'should be able to authenticate user based on the current user property set on the event', ->
      @event.set 'user', 'grayden'
      @event.set 'current_user', 'grayden'
      expect(@event.editAllowed()).toBeTruthy()

    it 'should use the explicit argument to override the current user property', ->
      @event.set 'user', 'grayden'
      @event.set 'current_user', 'grayden'
      expect(@event.editAllowed('gsmith')).toBeFalsy()

  describe 'top ranked', ->
    beforeEach ->
      @events = new FK.Collections.EventList FK.SpecHelpers.Events.UpvotedEvents
      @topEvents = @events.topRanked(3, moment(), moment().add('days', 7))

    it 'should be able to find an arbitary number of the top ranked events', ->
      expect(@topEvents.length).toBe(3)

    it 'should be finding events that are top ranked', ->
      expect(@topEvents[0].upvotes()).toBe(11)
      expect(@topEvents[1].upvotes()).toBe(11)
      expect(@topEvents[2].upvotes()).toBe(9)

    it 'should be finding events ordered by date after ranking', ->
      expect(@topEvents[0].get('name')).toBe('event 5')
      expect(@topEvents[1].get('name')).toBe('event 6')

describe 'event list', ->
  describe 'fetching events', ->
    beforeEach ->
      @xhr = sinon.useFakeXMLHttpRequest()
      @requests = []
      @xhr.onCreate = (xhr) =>
        @requests.push xhr

      @events = new FK.Collections.EventList()

    afterEach ->
      @xhr.restore()

    it "should be able to fetch startup events", ->
      topRanked = 10
      eventsPerDay = 3
      eventsMinimum = 10
      @events.fetchStartupEvents(topRanked, eventsPerDay, eventsMinimum)
      expect(@requests.length).toBe(1)
      expect(@requests[0].url).toBe('api/events/startupEvents?howManyTopRanked=10&howManyEventsPerDay=3&howManyEventsMinimum=10')

    it "should be able to getch more events by a date", ->
      @events.reset([
        { _id: 1 }
        { _id: 2 }
      ])
      @events.fetchMoreEventsByDate(moment(), 10)
      expect(@requests.length).toBe(1)

      @requests[0].respond(200, { "Content-Type": "application/json"},
        JSON.stringify([
          { _id: 3}
        ])
      )

      expect(@events.length).toBe(3)

    describe "getting events from the events list by date", ->
      beforeEach ->
        @events.reset(FK.SpecHelpers.Events.SimpleEvents)

      it "should be able to get a list of events from the collection by date", ->
        expect(@events.eventsByDate(moment(), 3).length).toBe(3)

      it "should get the event with the highest number of upvotes first", ->
        expect(@events.eventsByDate(moment(), 3)[0].upvotes()).toBe(5)

      it "should get the events with the lowest number of upvotes last", ->
        expect(@events.eventsByDate(moment(), 3)[2].upvotes()).toBe(2)

      it "should be able to skip a given number of events", ->
        expect(@events.eventsByDate(moment(), 2).length).toBe(2)

      it "should be able to exclude certain events", ->
        expect(@events.eventsByDate(moment(), 2, [FK.SpecHelpers.Events.SimpleEvents[1]])[0].id).not.toEqual(2)
        
      
describe 'event block', ->
  beforeEach ->
    @block = new FK.Models.EventBlock
    
  it 'can detect if the date of the event block is today', ->
    expect(@block.isToday()).toBeTruthy()

  it 'can detect if the date of the event block is not today even within 1 day', ->
    @block = new FK.Models.EventBlock
      date: moment().add({hours: 4, days: -1})
    expect(@block.isToday()).toBeFalsy()

  it 'can detect if the date of the event block is not today', ->
    @block = new FK.Models.EventBlock
      date: moment().days(-2)

    expect(@block.isToday()).toBeFalsy()

  it 'can detect if the date of the event block is today ignoring seconds', ->
    @block = new FK.Models.EventBlock
      date: moment().seconds(-2)

    expect(@block.isToday()).toBeTruthy()

  describe 'adding more events to a block', ->
    beforeEach ->
      @events = new FK.Collections.EventList(FK.SpecHelpers.Events.TodayEvents)

    it "should be able to add some events to its events collection", ->
      @block.addEvents(new FK.Models.Event { _id: 1, datetime: moment().add('seconds', 2) })
      expect(@block.events.length).toBe(1)

    it "should not be able to add events past the current limit on the block", ->
      @block.set('event_limit', 2)
      @block.addEvents(FK.SpecHelpers.Events.TodayEvents)
      expect(@block.events.length).toBe(2)

    it "should notice when not enough events have been added to satisfy the limit and reduce the limit", ->
      @block.increaseLimit(2)
      @block.addEvents(FK.SpecHelpers.Events.TodayEvents)
      @block.checkLimit()
      expect(@block.get('more_events_available')).toBeFalsy()
      expect(@block.get('event_limit')).toBe(4)

  describe "knowing how many events are in a block", ->
    beforeEach ->
      @block.set('date', moment().startOf('day'))
      @xhr = sinon.useFakeXMLHttpRequest()
      @requests = []
      @xhr.onCreate = (xhr) =>
        @requests.push xhr

      describe "add events then respond", ->
        beforeEach ->
          @block.addEvents FK.SpecHelpers.Events.TodayEvents
          @block.checkEventCount()
          @requests[0].respond(200, "Content-Type": 'application/json', JSON.stringify({count: 3}))

        it "should be able to check how many events are expected in this block", ->
          expect(@block.get('event_max_count')).toBe(3)

        it "should realize that there are no more events for this block", ->
          expect(@block.get('more_events_available')).toBeFalsy()

      describe "respond then add events", ->
        beforeEach ->
          @block.checkEventCount()
          @requests[0].respond(200, "Content-Type": 'application/json', JSON.stringify({count: 3}))
          @block.addEvents FK.SpecHelpers.Events.TodayEvents

        it "should be able to check how many events are expected in this block", ->
          expect(@block.get('event_max_count')).toBe(3)

        it "should realize that there are no more events for this block", ->
          expect(@block.get('more_events_available')).toBeFalsy()

describe "event block list", ->
  beforeEach ->
    @blocks = new FK.Collections.EventBlockList([
      {id: 1, date: moment(moment().add('days', 1).format('YYYY-MM-DD'))}
    ])

  it "should be able to add events to a block by date", ->
    event = new FK.Models.Event
      datetime: moment().add('days', 1)
    @blocks.addEventToBlock(moment(event.get('fk_datetime').format('YYYY-MM-DD')), event)
    expect(@blocks.get(1).events.length).toBe(1)

  describe "adding an event without a block already created", ->
    beforeEach ->
      event = new FK.Models.Event
        datetime : moment().add('days', 3)
      @blocks.addEventToBlock(moment(event.get('fk_datetime').format('YYYY-MM-DD')), event)

    it "should have created a new block for the event", ->
      expect(@blocks.length).toBe(2)

    it "should have the latest date as the last block", ->
      expect(@blocks.last().get('date').format('YYYY-MM-DD')).toBe(moment().add('days', 3).format('YYYY-MM-DD'))

    it "should be able to create a block if the needed block does not exist", ->
      expect(@blocks.last().events.length).toBe(1)
