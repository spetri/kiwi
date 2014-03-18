FK.App.module "Events.EventPage", (EventPage, App, Backbone, Marionette, $, _) ->

  @startWithParent = false

  @addInitializer (event) ->
    @event = event
    @loadSocialNetworking()
    @event.set 'current_user', App.request('currentUser').get('username')
    if @event.get('location_type') is 'national'
      @event.set 'country_full_name', App.request('countryName', @event.get('country'))
    
    @view = new EventPage.EventPageLayout
    @eventCardView = new EventPage.EventCard
      model: @event

    @listenTo @eventCardView, 'click:edit', @triggerEditEvent
    @listenTo @eventCardView, 'click:reminders', @toggleShowReminders

    @listenTo @event, 'destroy', @triggerEventList

    @eventCardView.on 'show', () =>
      @renderSocialNetworking()
      
    @view.onShow = () =>
      @view.eventCardRegion.show @eventCardView

    @view.onClose = () =>
      @stop()

    event.on 'change', (event) =>
      App.request('events').add event, merge: true

    Backbone.history.navigate('events/show/' + event.id, trigger : false)

    App.mainRegion.show @view

  @triggerEditEvent = (args) ->
    event = args.model
    event.fetch(
      success: () =>
        Backbone.history.navigate('events/edit/' + event.id, trigger : true)
    )

  @triggerEventList = () =>
    App.vent.trigger 'container:all'

  @toggleShowReminders = () ->
    return @closeReminders() if @remindersView and not @remindersView.isClosed

    @remindersView = new EventPage.EventReminders
      model: @event

    @eventCardView.reminders.show @remindersView

  @closeReminders = () ->
    @remindersView.close() if @remindersView

  @loadSocialNetworking = () ->
    @googleApi = $.Deferred()
    @facebookApi = $.Deferred()
    @twitterApi = $.Deferred()
    $.getScript('https://apis.google.com/js/plusone.js?onload=onLoadCallback',
      () =>
        @googleApi.resolve()
    )
    $.getScript('http://platform.twitter.com/widgets.js',
      () =>
        @facebookApi.resolve()
    )
    $.getScript('//connect.facebook.net/en_US/all.js#xfbml=1',
      () =>
        @twitterApi.resolve()
    )

  @renderSocialNetworking = () =>
    $.when(@googleApi, @facebookApi, @twitterApi).then =>
      gapi.plusone.go()
      FB.XFBML.parse()
      twttr.widgets.load()

  @addFinalizer () ->
    @view.close()
    @stopListening()


  class EventPage.EventPageLayout extends Marionette.Layout
    template: FK.Template('event_page')
    className: 'event-page col-md-8'

    regions:
      eventCardRegion: '.event-card-region'
      eventDisqusRegion: '.event-disqus-region'
