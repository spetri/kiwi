describe "Events.EventCard", ->
  beforeEach ->
    @event = new FK.Models.Event()
    @view = new FK.App.Events.EventPage.EventCard
      model: @event
    loadFixtures "testbed"
    $('#testbed').html @view.render().el

  afterEach ->
    @view.close()

  it "should be able to trigger an upvote", ->
    $('.event-upvotes').click()
    expect($('.event-upvotes').html()).toContain(1)
