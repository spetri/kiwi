describe "Events.EventForm", ->

  beforeEach () ->
    loadFixtures 'app_fixture'
 
  afterEach () ->
    FK.App.Events.EventForm.stop()

  xdescribe "when shown with an event model", () ->

    beforeEach () ->
      @event = new FK.Models.Event
        name: 'Ball drop'
        location_type: 'national'
        country: 'AE'
      FK.App.Events.EventForm.start @event

    it "should have the event name shown", () ->
      expect($('#name').val()).toBe(@event.get('name'))

    it "should have the correct location shown (location type)", () ->
      expect($('[value="national"]').is(':checked')).toBeTruthy()
      expect($('[name="location_type"]:checked').length).toBe(1)

    it "should have the correct country selected", () ->
      expect($('.event-form [name="country"]').attr('disabled')).toBeFalsy()
      expect($('.event-form [name="country"] :selected').val()).toBe('AE')
