describe "Events.EventCard", ->
  beforeEach ->
    @event = new FK.Models.Event()
    @event.set 'upvote_allowed', true
    @view = new FK.App.Events.EventPage.EventCard
      model: @event
    @view.render().el
    @xhr = sinon.useFakeXMLHttpRequest()

  afterEach ->
    @xhr.restore()
    @view.close()

  xit "should be able to trigger an upvote", ->
    @view.$('.event-upvotes').click()
    expect(@view.$('.event-upvotes').html()).toContain(1)
