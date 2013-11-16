#= require application

describe "Events.EventPage", () ->
  beforeEach () ->
    @event = new FK.Models.Event
      name: 'Ball Drop'

    loadFixtures 'app_fixture'
    FK.App.Events.EventPage.start @event

  afterEach () ->
    FK.App.Events.EventPage.stop()

  it "should render an event page on show in the main region", () ->
    expect($('.event-card').length).toBe(1)

  it "should destroy the event page on module stop", () ->
    FK.App.Events.EventPage.stop()
    expect($('.event-card').length).toBe(0)
