# use require to load any .js file available to the asset pipeline
#= require application

describe "Event", ->
  loadFixtures 'event_fixture' # located at 'spec/javascripts/fixtures/event_fixture.html.erb'
  it "Default country to be US", ->
    v = new FK.Models.Event()
    expect(v.get('country')).toEqual('US')

  describe "when working with dates and times", ->
    it "can create a local time on set", ->
      event = new FK.Models.Event datetime: moment("2013-12-12, 13:00 GMT-500")
      expect(event.get('local_time')).toBe('1:00 PM')

    it "can detect TV times", ->
      v = new FK.Models.Event time_format: 'tv_show', datetime: moment("2013-12-12, 16:00 GMT-500")
      expect(v.get('time')).toEqual('4/3c')
      
      v = new FK.Models.Event time_format: 'tv_show', datetime: moment("2013-12-12, 1:00 GMT-500")
      expect(v.get('time')).toEqual('1/12c')
      
      v = new FK.Models.Event time_format: 'tv_show', datetime: moment("2013-12-12, 20:00 GMT+200")
      expect(v.get('time')).toEqual('1/12c')

    it "can get a datetime in the local timezone without changing it", ->
      v = new FK.Models.Event
        datetime: moment().zone(0)
      expect(v.in_my_timezone(v.get('datetime')).hour()).toBe(moment().hour())
      expect(v.get('datetime').hour()).toBe(moment().zone(0).hour())

    it "can detect if an event is in the future", ->
      event = new FK.Models.Event
        datetime: moment().add('seconds', 10)

      expect(event.in_future()).toBeTruthy()

    it "can detect if an event with a recurring time format is in the future", ->
      event = new FK.Models.Event
        datetime: moment().toDate()
        local_time: moment().add('hours', 4).format('h:mm A')
        time_format: 'recurring'

      expect(event.in_future()).toBeTruthy()

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

    describe "getting more events from the events list by date", ->
      beforeEach ->
        @events.reset(FK.SpecHelpers.Events.SimpleEvents)

      xit "should be able to get events by date from the event list through a deferred", ->
        resolvedEvents = []
        deferred = @events.getEventsByDate(moment(), 3, 0)
        
        deferred.done( (events) =>
          _.each(events, (event) =>
            resolvedEvents.push event
          )
        )

        expect(resolvedEvents.length).toBe(3)

      xit "should be able to skip a given number of events", ->
        resolvedEvents = []
        deferred = @events.getEventsByDate(moment(), 2, 1)
        deferred.done( (events) =>
          _.each(events, (event) =>
            resolvedEvents.push event
          )
        )

        expect(resolvedEvents.length).toBe(2)

      xit "should be able to return less than the number of events available", ->
        resolvedEvents = []
        deferred = @events.getEventsByDate(moment(), 1, 0)
        deferred.done( (events) =>
          _.each(events, (event) =>
            resolvedEvents.push event
          )
        )

        expect(resolvedEvents.length).toBe(1)

      xit "should attempt a server call if the number of events are less than requested", ->
        resolvedEvents = []
        deferred = @events.getEventsByDate(moment(), 4, 0)
        deferred.done( (events) =>
          _.each(events, (event) =>
            resolvedEvents.push event
          )
        )

        expect(@requests.length).toBe(1)
        @requests[0].respond(200, { "Content-Type": "application/json" }, JSON.stringify([{_id: 5, datetime: moment().add('minutes', 20)}]))
        expect(resolvedEvents.length).toBe(4)
        expect(@events.length).toBe(5)

  describe 'making blocks', ->
    beforeEach ->
      @events = new FK.Collections.EventList FK.SpecHelpers.Events.SimpleEvents
      @blocks = @events.asBlocks()

    it "should have a block for each date", ->
      expect(@blocks.length).toBe(2)

  describe 'making blocks with past events', ->
    beforeEach ->
      @events = new FK.Collections.EventList FK.SpecHelpers.Events.PastTodayEvents
      @blocks = @events.asBlocks()

    it "should only have blocks for days that have events in the future", ->
      expect(@blocks.length).toBe(1)

    it "should not have today as the date of a block", ->
      expect(@blocks[0].get('date').format('YYYY-MM-DD')).not.toEqual(moment().format('YYYY-MM-DD'))

describe 'event block', ->
  beforeEach ->
    @block = new FK.Models.EventBlock
    
  it 'can detect if the date of the event block is today', ->
    expect(@block.isToday()).toBeTruthy()

  it 'can detect if the date of the event block is not today', ->
    @block = new FK.Models.EventBlock
      date: moment().days(-2)

    expect(@block.isToday()).toBeFalsy()

  it 'can detect if the date of the event block is today ignoring seconds', ->
    @block = new FK.Models.EventBlock
      date: moment().seconds(-2)

    expect(@block.isToday()).toBeTruthy()

  describe 'fetching more events for block', ->
    beforeEach ->
      @events = new FK.Collections.EventList
      @events.reset(FK.SpecHelpers.Events.TodayEvents)
      @block = new FK.Models.EventBlock()
      @xhr = sinon.useFakeXMLHttpRequest()
      @requests = []
      @xhr.onCreate = (xhr) =>
        @requests.push xhr

    afterEach ->
      @xhr.restore()

    xit "should be able to fetch more events from an event collection", ->
      @block.fetchMore(3, @events)
      expect(@block.events.length).toBe(3)

    xit "should be able to notice that no more events are available", ->
      @block.increaseLimit(2)
      @block.fetchMore(5, @events)
      @requests[0].respond(200, { "Content-Type": "application/json"}, JSON.stringify([]))
      expect(@block.get('more_events_available')).toBeFalsy()

  describe 'adding more events to a block', ->
    beforeEach ->
      @events = new FK.Collections.EventList(FK.SpecHelpers.Events.TodayEvents)
      @block = new FK.Models.EventBlock()

    it "should be able to add some events to its events collection", ->
      @block.addEvents(new FK.Models.Event { _id: 1, datetime: moment().add('seconds', 2) })
      expect(@block.events.length).toBe(1)

    it "should not be able to add events past the current limit on the block", ->
      @block.set('event_limit', 2)
      @block.addEvents(FK.SpecHelpers.Events.TodayEvents)
      expect(@block.events.length).toBe(2)

    it "should not be able to add events past the current limit on the block when the block has some events", ->
      @block.addEvents(FK.SpecHelpers.Events.TodayEvents[0])
      @block.addEvents(FK.SpecHelpers.Events.TodayEvents[1..3])
      expect(@block.events.length).toBe(3)

    xit "should be able to up the event limit and get more events", ->
      @block.set('event_limit', 1)
      @block.addEvents(@events.models)
      @block.increaseLimit(1)
      @block.fetchMore(1, @events)
      expect(@block.events.length).toBe(2)

    describe "adding events from the past", ->
      beforeEach ->
        @block.addEvents([
          new FK.Models.Event { _id: 2, datetime: moment().add('seconds', 5) }
          new FK.Models.Event { _id: 3, datetime: moment().subtract('seconds', 1) }
        ])

      it "should not have every event added", ->
        expect(@block.events.length).toBe(1)

      it "should only have events after now", ->
        expect(@block.events.first().get('_id')).toBe(2)

describe "event block list", ->
  beforeEach ->
    @blocks = new FK.Collections.EventBlockList([
      {id: 1, date: moment().toDate()}
      {id: 2, date: moment().add('days', 1).toDate()}
    ])

  it "should be able to add events to a block by date", ->
    @blocks.addEventsToBlock(moment(), FK.SpecHelpers.Events.TodayEvents)
    expect(@blocks.get(1).events.length).toBe(3)

  it "should be able to create a block if the needed block does not exist", ->
    @blocks.addEventsToBlock(moment().add('days', 3), FK.SpecHelpers.Events.TodayEvents)
    expect(@blocks.last().events.length).toBe(3)

