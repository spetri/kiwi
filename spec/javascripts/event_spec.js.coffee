# use require to load any .js file available to the asset pipeline
#= require application
describe "Event", ->
  it "Default country to be US", ->
    v = new FK.Models.Event()
    expect(v.get('country')).toEqual('US')

  describe "date and time", ->
    beforeEach ->
      @event = new FK.Models.Event()

    describe "normal datetime", ->
      describe "today in the future", ->
        beforeEach ->
          @datetime = moment('16-jan-2015 12:00').add(minutes: 1)
          @event.moveToDateTime(@datetime.format('YYYY-MM-DD'), @datetime.format('hh:mm A'))

        it "should be in the future", ->
          expect(@event.inFuture()).toBeTruthy()

        it "should be on the current date", ->
          expect(@event.isOnDate(moment(@datetime))).toBeTruthy()

        it "should provide the correct datetime date", ->
          expect(@event.get('fk_datetime').format('YYYY-MM-DD')).toBe(@datetime.format('YYYY-MM-DD'))

        it "should provide the correct datetime time", ->
          expect(@event.get('fk_datetime').format('HH:mm:SS')).toBe(@datetime.format('HH:mm:SS'))

        it "should provide the date in the forekast format", ->
          expect(@event.get('dateAsString')).toEqual('Friday, Jan 16th, 2015')

        it "should provide the time in the forekast format", ->
          expect(@event.get('timeAsString')).toEqual('12:01 PM')

      describe "in the past", ->
        beforeEach ->
          @datetime = moment('16 jan 2013 12:00').add(minutes : -1)
          @event.moveToDateTime(@datetime.format('YYYY-MM-DD'), @datetime.format('hh:mm A'))

        it "should not be in the future", ->
          expect(@event.inFuture()).toBeFalsy()

        it "should provide the correct datetime time", ->
          expect(@event.get('fk_datetime').format('HH:mm:SS')).toBe(@datetime.format('HH:mm:SS'))

        it "should provide the correct time in the forekast format", ->
          expect(@event.get('timeAsString')).toEqual('11:59 AM')

      describe "days in the future", ->
        beforeEach ->
          @datetime = moment().add(days: 3)
          @event.moveToDateTime(@datetime.format('YYYY-MM-DD'), @datetime.format('hh:mm A'))

        it "should be in the future", ->
          expect(@event.inFuture()).toBeTruthy()

        it "should be on the date in the future", ->
          expect(@event.isOnDate(@datetime)).toBeTruthy()

        it "should provide the correct datetime date", ->
          expect(@event.get('fk_datetime').format('YYYY-MM-DD')).toBe(@datetime.format('YYYY-MM-DD'))

        it "should provide the date in the forekast format", ->
          expect(@event.get('dateAsString')).toEqual('Sunday, Jan 19th, 2014')
          
    describe "all day events", ->
      describe "today", ->
        beforeEach ->
          @datetime = moment()
          @event.set (is_all_day: true)
          @event.moveToDateTime(@datetime.format('YYYY-MM-DD'), @datetime.format('hh:mm A'))

        it "should be on today's date", ->
          expect(@event.isOnDate(@datetime))

        it "should be in the future", ->
          expect(@event.inFuture()).toBeTruthy()

        it "should have a datetime at the start of today", ->
          expect(@event.get('fk_datetime').format('HH:mm:SS')).toBe('00:00:00')

        it "should have a datetime that is the same date as the date originally entered", ->
          expect(@event.get('fk_datetime').format('YYYY-MM-DD')).toBe(@datetime.format('YYYY-MM-DD'))

        it "should have all day printed as the time string", ->
          expect(@event.get('timeAsString')).toBe('All Day')

        it "should have the current datetime date printed in the forekast format", ->
          expect(@event.get('dateAsString')).toBe('Thursday, Jan 16th, 2014')

      describe "in the past", ->
        beforeEach ->
          @datetime = moment().add( days: -1 )
          @event.set(is_all_day: true)
          @event.moveToDateTime(@datetime.format('YYYY-MM-DD'), @datetime.format('hh:mm A'))

        it "should be on yesterday's date", ->
          expect(@event.isOnDate(@datetime)).toBeTruthy()

        it "should not be in the future", ->
          expect(@event.inFuture()).toBeFalsy()

        it "should have a datetime at the start of yesterday", ->
          expect(@event.get('fk_datetime').format('HH:mm:SS')).toBe('00:00:00')

        it "should have a datetime that is the same date as the date originally entered", ->
          expect(@event.get('fk_datetime').format('YYYY-MM-DD')).toBe(@datetime.format('YYYY-MM-DD'))

      describe "days in the future", ->
        beforeEach ->
          @datetime = moment().add( days: 4 )
          @event.set(is_all_day: true)
          @event.moveToDateTime(@datetime.format('YYYY-MM-DD'), @datetime.format('hh:mm A'))

        it "should be on the future date date", ->
          expect(@event.isOnDate(@datetime)).toBeTruthy()

        it "should be in the future", ->
          expect(@event.inFuture()).toBeTruthy()

        it "should have a datetime at the start of the day", ->
          expect(@event.get('fk_datetime').format('HH:mm:SS')).toBe('00:00:00')

        it "should have a datetime that is the same date as the date originally entered", ->
          expect(@event.get('fk_datetime').format('YYYY-MM-DD')).toBe(@datetime.format('YYYY-MM-DD'))

    describe "tv time", ->
      describe "setting time format after", ->
        beforeEach ->
          @datetime = moment('16 jan 2015 12:00')
          @event.set(time_format: 'tv_show')
          @event.moveToDateTime(@datetime.format('YYYY-MM-DD'), @datetime.format('hh:mm A'))

        it "should have the datetime in tv format", ->
          expect(@event.get('timeAsString')).toBe('12:00/11:00c')

      describe "today in the future pm", ->
        beforeEach ->
          @datetime = moment('16 jan 2015 19:20')
          @event.set(time_format: 'tv_show')
          @event.moveToDateTime(@datetime.format('YYYY-MM-DD'), @datetime.format('hh:mm A'))

        it "should be on today's date", ->
          expect(@event.isOnDate(moment('16 jan 2015 19:20'))).toBeTruthy()

        it "should use the date of the event as the relative date", ->
          expect(@event.get('fk_datetime').format('YYYY-MM-DD')).toBe('2015-01-16')

        it "should use the time of the event as the relative time", ->
          expect(@event.get('fk_datetime').format('HH:mm:SS')).toBe('19:20:00')

        it "should use eastern time as the relative timezone", ->
          console.log @event.get('fk_datetime').toString()
          expect(@event.get('fk_datetime').format('ZZ')).toBe('-0500')

        it "should be in the future", ->
          expect(@event.inFuture()).toBeTruthy()

        it "should have a time in the fk format", ->
          expect(@event.get('timeAsString')).toBe('7:20/6:20c')

        it "should have the fk date format for the as date string", ->
          expect(@event.get('dateAsString')).toBe('Friday, Jan 16th, 2015')

        describe "today in the future am", ->
          beforeEach ->
            @datetime = moment('16 jan 2015 22:00')
            @event.set(time_format: 'tv_show')
            @event.moveToDateTime(@datetime.format('YYYY-MM-DD'), @datetime.format('hh:mm A'))

          it "should have a time in the fk format", ->
            expect(@event.get('timeAsString')).toBe('10:00/9:00c')

        describe "today in the future at 1pm", ->
          beforeEach ->
            @datetime = moment('16 jan 2015 1:00')
            @event.set(time_format: 'tv_show')
            @event.moveToDateTime(@datetime.format('YYYY-MM-DD'), @datetime.format('hh:mm A'))

          it "should have a time in the fk format", ->
            expect(@event.get('timeAsString')).toBe('1:00/12:00c')

      describe "in the past", ->
        beforeEach ->
          @datetime = moment().add( days: -1 )
          @event.set(time_format: 'tv_show')
          @event.moveToDateTime(@datetime.format('YYYY-MM-DD'), @datetime.format('hh:mm A'))

        it "should be on yesterday's date", ->
          expect(@event.isOnDate(@datetime)).toBeTruthy()

        it "should not be in the future", ->
          expect(@event.inFuture()).toBeFalsy()

    describe "recurring events later today", ->
      beforeEach ->
        @datetime = moment(hour:21)
        @event.set(time_format: 'recurring')
        @event.moveToDateTime(@datetime.format('YYYY-MM-DD'), @datetime.format('hh:mm A'))

      it "should be on the current date", ->
        expect(@event.isOnDate(@datetime)).toBeTruthy()

      it "should have today as its date", ->
        expect(@event.get('fk_datetime').format('YYYY-MM-DD')).toBe('2014-01-16')

      it "should have a fixed time as its time", ->
        expect(@event.get('fk_datetime').format('HH:mm:SS')).toBe('21:00:00')

      it "should have a date in the fk format", ->
        expect(@event.get('dateAsString')).toBe('Thursday, Jan 16th, 2014')

      it "should have a time in the fk format", ->
        expect(@event.get('timeAsString')).toBe('9:00 PM')

    describe "recurring events in the past", ->
      beforeEach ->
        @datetime = moment(hour: 3).add(days: -2)
        @event.set(time_format: 'recurring')
        @event.moveToDateTime(@datetime.format('YYYY-MM-DD'), @datetime.format('hh:mm A'))

      it "should be on the set date", ->
        expect(@event.isOnDate(@datetime)).toBeTruthy()

      it "should not be in the future", ->
        expect(@event.inFuture()).toBeFalsy()

      it "should have the datetime as its date", ->
        expect(@event.get('fk_datetime').format('YYYY-MM-DD')).toBe('2014-01-14')

      it "should have a fixed time as its time", ->
        expect(@event.get('fk_datetime').format('HH:mm:SS')).toBe('03:00:00')

      it "should have a date in the fk format", ->
        expect(@event.get('dateAsString')).toBe('Tuesday, Jan 14th, 2014')

      it "should have a time in the fk format", ->
        expect(@event.get('timeAsString')).toBe('3:00 AM')

    describe "recurring events at 12 PM", ->
      beforeEach ->
        @datetime = moment(hour: 12)
        @event.set(time_format: 'recurring')
        @event.moveToDateTime(@datetime.format('YYYY-MM-DD'), @datetime.format('HH:mm A'))

      it "should still be at 12 hours PM", ->
        expect(@event.get('timeAsString')).toBe('12:00 PM')
 
    it "can get a datetime in the local timezone without changing it", ->
      v = new FK.Models.Event
        datetime: moment().zone(0)
      hours = v.get('fk_datetime').clone().zone(moment().zone()).hour()
      expect(v.in_my_timezone(v.get('fk_datetime')).hour()).toBe(hours)


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
      @topEvents = @events.topRanked(3, moment(), moment().add('days', 7), 'CA', ['ST'])

    it 'should be able to find an arbitrary number of the top ranked events', ->
      expect(@topEvents.length).toBe(3)

    it 'should be finding events that are top ranked', ->
      expect(@topEvents[0].upvotes()).toBe(11)
      expect(@topEvents[1].upvotes()).toBe(11)
      expect(@topEvents[2].upvotes()).toBe(9)

    it 'should be finding events ordered by date after ranking', ->
      expect(@topEvents[0].get('name')).toBe('event 5')
      expect(@topEvents[1].get('name')).toBe('event 6')

  describe 'description', ->
    beforeEach ->
      @event = new FK.Models.Event

    #Ignored while we use a markdown parser, this spec may be fully obsolete soon - grayden
    xit "should be able to recognize various forms of hyperlinks and parse them", ->
      hyperlinks = ['http://google.ca', 'http://google.ca', 'http://www.google.ca', 'http://www.google.ca/chrome', 'http://www.google.ca/chrome.php', 'http://www.google.com/chrome/asdf/download.asp', 'http://google.ca/chrome_download/file.asp']
      _.each(hyperlinks, (hyperlink) =>

        desc = "Find out more on this event at #{hyperlink} the search engine"
        descParsed = "Find out more on this event at <a target=\"_blank\" href=\"#{hyperlink}\">#{hyperlink}</a> the search engine"
        @event.set('description', desc)
        expect(@event.descriptionParsed()).toBe(descParsed)

      )

    #Ignored while we use a markdown parser, this spec may be fully obsolete soon - grayden
    xit "should be able to tag on http:// if not in the hyperlink", ->
      @event.set('description', 'google.ca')
      expect(@event.descriptionParsed()).toBe('<a target=\"_blank\" href=\"http://google.ca\">google.ca</a>')

  describe 'validation', ->
    beforeEach ->
      @event = new FK.Models.Event()
      @event.set('name', 'Great event')
      @event.set('datetime', moment())
      @event.set('subkast', 'OTH')

    it "should not be valid when the event does not a have name", ->
      @event.unset('name')
      expect(@event.isValid()).toBeFalsy()
      expect(@event.validationError.length).toBe(1)

    it "should not have a name longer than 100 characters", ->
      @event.set('name', 'aasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdafsdfasdfasdfasdfasdf')
      expect(@event.isValid()).toBeFalsy()
      expect(@event.validationError.length).toBe(1)

    it "should not be valid if it does not have a datetime", ->
      @event.unset('datetime')
      expect(@event.isValid()).toBeFalsy()
      expect(@event.validationError.length).toBe(1)

    it "should not be valid if it does not have a subkast", ->
      @event.set('subkast', 'OTM')
      expect(@event.isValid()).toBeFalsy()

describe 'event list', ->
  describe 'top ranked sorting', ->
    beforeEach ->
      @events = new FK.Collections.TopRankedEventList()
      @events.reset [
        { upvotes: 2, datetime: moment().add(hours: 4), name: 'Google Day' }
        { upvotes: 6, datetime: moment().add(hours: -2), name: 'Groundhog Day' }
        { upvotes: 4, datetime: moment().add(hours: -3), name: 'Moose Day' }
        { upvotes: 9, datetime: moment().add(hours: -3), name: 'Koala Day' }
        { upvotes: 6, datetime: moment(), name: 'Zoom day' }
        { upvotes: 6, datetime: moment(), name: 'The event' }
      ]

    it "should have the event with the highest number of upvotes first", ->
      expect(@events.at(0).get('name')).toBe('Koala Day')

    it "should have the event with the next highest number of upvotes, and the earliest date next", ->
      expect(@events.at(1).get('name')).toBe('Groundhog Day')

    it "should have the rest of the events ordered by upvote", ->
      expect(@events.at(4).get('name')).toBe('Moose Day')
      expect(@events.at(5).get('name')).toBe('Google Day')

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
      @events.fetchStartupEvents("CA", ["ST", "SE"], topRanked, eventsPerDay, eventsMinimum)
      expect(@requests.length).toBe(1)

    it "should be able to fetch more events by a date", ->
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
        @country = "CA"
        @subkasts = ["ST", "SE"]
        @events.reset(FK.SpecHelpers.Events.SimpleEvents)

      it "should be able to get a list of events from the collection by date", ->
        expect(@events.eventsByDate(moment(), @country, @subkasts, 3).length).toBe(3)

      it "should get the event with the highest number of upvotes first", ->
        expect(@events.eventsByDate(moment(), @country, @subkasts, 3)[0].upvotes()).toBe(5)

      it "should get the events with the lowest number of upvotes last", ->
        expect(@events.eventsByDate(moment(), @country, @subkasts, 3)[2].upvotes()).toBe(2)

      it "should be able to skip a given number of events", ->
        expect(@events.eventsByDate(moment(), @country, @subkasts, 2).length).toBe(2)

      it "should be able to exclude certain events", ->
        expect(@events.eventsByDate(moment(), @country, @subkasts, 2, [FK.SpecHelpers.Events.SimpleEvents[1]])[0].id).not.toEqual(2)

      describe "and filtering by subkasts", ->
        beforeEach ->
          @events.reset(FK.SpecHelpers.Events.FilterableEvents)

        it "should only get events that match the filter by country or are international", ->
          expect(@events.eventsByDate(moment(), "CA", ['ST', 'SE'], 4).length).toBe(3)

        it "should only get events that match the filter by country and subkast", ->
          expect(@events.eventsByDate(moment(), "CA", ['ST'], 3).length).toBe(2)
        
      
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
    @blocks.addEventToBlock(moment(event.get('fk_datetime').format('YYYY-MM-DD')), 'CA', ['ST', 'SE'], event)
    expect(@blocks.get(1).events.length).toBe(1)

  describe "adding an event without a block already created", ->
    beforeEach ->
      event = new FK.Models.Event
        datetime : moment().add('days', 3)
      @blocks.addEventToBlock(moment(event.get('fk_datetime').format('YYYY-MM-DD')), 'CA', ['ST', 'SE'], event)

    it "should have created a new block for the event", ->
      expect(@blocks.length).toBe(2)

    it "should have the latest date as the last block", ->
      expect(@blocks.last().get('date').format('YYYY-MM-DD')).toBe(moment().add('days', 3).format('YYYY-MM-DD'))

    it "should be able to create a block if the needed block does not exist", ->
      expect(@blocks.last().events.length).toBe(1)
