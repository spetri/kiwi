#= require application

describe "Events.EventPage", () ->
  beforeEach () ->
    @event = new FK.Models.Event
      name: 'Ball Drop'

    loadFixtures 'app_fixture'
    FK.App.Events.EventPage.start()
    FK.App.Events.EventPage.show @event

  afterEach () ->
    FK.App.Events.EventPage.stop()

  it "should render an event page on show in the main region", () ->
    expect($('.event-card').length).toBe(1)

  it "should destroy the event page on module close", () ->
    FK.App.Events.EventPage.close()
    expect($('.event-card').length).toBe(0)
