FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  class EventList.EventCollapsed extends Backbone.Marionette.ItemView
    template: FK.Template('event_collapsed')
    className: 'event'
    tagName: 'div'

    templateHelpers: () =>
      return {
        fullSubkastName: => @model.fullSubkastName()
        time: => @model.get('timeAsString')
      }

    ui:
      upvotesIcon: '.upvote-container i'
      upvotesContainer: '.upvote-container'

    events:
      'click .upvote-container': 'toggleUpvote'
      'mouseover .upvote-container': 'showX'
      'mouseout .upvote-container': 'hideX'

    triggers:
      'click .event-name,img': 'click:open'

    toggleUpvote: (e) =>
      @model.upvoteToggle()

    showX: (e) =>
      e.preventDefault()
      if @model.userHasUpvoted()
        @ui.upvotesIcon.addClass('glyphicon-remove')
        @ui.upvotesIcon.removeClass('glyphicon-ok')

    hideX: (e) =>
      e.preventDefault()
      if @model.userHasUpvoted()
        @ui.upvotesIcon.removeClass('glyphicon-remove')
        @ui.upvotesIcon.addClass('glyphicon-ok')

    modelEvents:
      'change:upvotes': 'refreshUpvotes'
      'change:have_i_upvoted': 'refreshUpvoted'

    refreshUpvotes: (event) =>
      @$('.upvote-counter').html event.upvotes()

    refreshUpvoted: (event) =>
      if event.userHasUpvoted()
        @ui.upvotesIcon.removeClass('glyphicon-chevron-up')
        @ui.upvotesIcon.addClass('glyphicon-ok')
      else
        @ui.upvotesIcon.addClass('glyphicon-chevron-up')
        @ui.upvotesIcon.removeClass('glyphicon-ok')
        @ui.upvotesIcon.removeClass('glyphicon-remove')

    refreshUpvoteAllowed: (event) =>
      if event.get('upvote_allowed')
        @ui.upvotesContainer.tooltip 'destroy'
      else
        @ui.upvotesContainer.tooltip
          title: 'Login to upvote'

    onRender: =>
      @refreshUpvotes @model
      @refreshUpvoted @model
      @refreshUpvoteAllowed @model
