FK.App.module "Events.EventPage", (EventPage, App, Backbone, Marionette, $, _) ->

  @startWithParent = false

  @addInitializer (event) ->
    @event = event
    @loadSocialNetworking()
    @updateEditAllowed(@event)

    @event.set 'upvote_allowed', FK.App.request('currentUser').get('logged_in')
    
    @view = new EventPage.EventPageLayout
    @eventCardView = new EventPage.EventCard
      model: @event

    @listenTo @eventCardView, 'click:edit', @triggerEditEvent
    @listenTo @event, 'change:user', @updateEditAllowed

    @eventCardView.on 'show', () =>
      @renderSocialNetworking()
      
    @view.onShow = () =>
      @view.eventCardRegion.show @eventCardView

    @view.onClose = () =>
      @stop()

    event.on 'change', (event) =>
      FK.Data.events.add event, merge: true

    Backbone.history.navigate('events/show/' + event.id, trigger : false)

    App.mainRegion.show @view

  @triggerEditEvent = (args) ->
    event = args.model
    App.vent.trigger 'container:new', event
    Backbone.history.navigate('events/edit/' + event.id, trigger : false)

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
 
  @updateEditAllowed = (event) =>
    event.set('edit_allowed', event.get('user') == FK.App.request('currentUser').get('username'))

  @addFinalizer () ->
    @view.close()
    @stopListening()


  class EventPage.EventPageLayout extends Marionette.Layout
    template: FK.Template('event_page')
    className: 'event-page'

    regions:
      eventCardRegion: '.event-card-region'
      eventDisqusRegion: '.event-disqus-region'
