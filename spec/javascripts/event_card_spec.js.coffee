describe "Events.EventCard", ->
  beforeEach ->
    @event = new FK.Models.Event()
    @event.set 'upvote_allowed', true
    @view = new FK.App.Events.EventPage.EventCard
      model: @event
    loadFixtures "testbed"
    $('#testbed').html @view.render().el
    @xhr = sinon.useFakeXMLHttpRequest()

  afterEach ->
    @xhr.restore()
    @view.close()

  it "should be able to trigger an upvote", ->
    $('.event-upvotes').click()
    expect($('.event-upvotes').html()).toContain(1)
