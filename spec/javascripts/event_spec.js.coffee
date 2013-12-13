# use require to load any .js file available to the asset pipeline
#= require application

describe "Event", ->
  loadFixtures 'event_fixture' # located at 'spec/javascripts/fixtures/event_fixture.html.erb'
  it "Default country to be US", ->
    v = new FK.Models.Event()
    expect(v.get('country')).toEqual('US')


  it "can get time in eastern", =>
    datetime = moment("2013-12-12, 16:00 GMT+200")
    v = new FK.Models.Event datetime: datetime
    expect(v.get('creation_timezone')).toEqual("GMT+100")
    expect(v.time_in_eastern()).toEqual('10:00')

  it "can detect TV times", =>
    v = new FK.Models.Event time_format: 'tv_show', datetime: moment("2013-12-12, 16:00 GMT+200")
    expect(v.time_in_eastern()).toEqual('10:00')
    expect(v.get('time')).toEqual('4/3c')
    
    v = new FK.Models.Event time_format: 'tv_show', datetime: moment("2013-12-12, 1:00 GMT+200")
    expect(v.get('time')).toEqual('1/12c')
    
    v = new FK.Models.Event time_format: 'tv_show', datetime: moment("2013-12-12, 20:00 GMT+200")
    expect(v.get('time')).toEqual('8/7c')

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
      @event.addReminder('grayden', '15m')
    
    it 'should be able to add a reminder', ->
      expect(@event.reminders.length).toBe(1)

    it 'should return the reminder created with the event id on it', ->
      reminder = @event.addReminder('grayden', '15m')
      expect(reminder.get('user')).toBe('grayden')
      expect(reminder.get('time_to_event')).toBe('15m')
      expect(reminder.get('event')).toBe(@event.id)

    it 'should be able to get a list of the reminder times in the event', ->
      @event.addReminder('grayden', '1h')
      @event.addReminder('grayden', '24h')

      expect(@event.reminderTimes()).toEqual(['15m', '1h', '24h'])

    it 'should be able to remove a reminder', ->
      @event.removeReminder 'grayden', '15m'
      expect(@event.reminderTimes().length).toBe(0)
