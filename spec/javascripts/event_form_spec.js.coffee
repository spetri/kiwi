describe "Events.EventForm", ->

  beforeEach () ->
    loadFixtures 'app_fixture'
    FK.App.Events.EventForm.start()
 
  afterEach () ->
    FK.App.Events.EventForm.stop()

  describe "when shown with an event model", () ->

    beforeEach () ->
      @event = new FK.Models.Event
        name: 'Ball drop'
      FK.App.Events.EventForm.show @event

    it "should have the event name shown", () ->
      debugger
      expect($('#name').val()).toBe(@event.get('name'))
