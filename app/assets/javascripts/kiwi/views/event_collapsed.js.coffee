FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  class EventList.EventCollapsed extends Backbone.Marionette.ItemView
    template: FK.Template('event_collapsed')
    className: 'event'
    tagName: 'div'

    ui:
      upvotesIcon: '.upvote-container i'
      upvotesContainer: '.upvote-container'

    events:
      'click .upvote-container': 'toggleUpvote'
      'mouseover .upvote-container': 'showX'
      'mouseout .upvote-container': 'hideX'

    triggers:
      'click .event-name,img': 'click:open'

    templateHelpers: =>
     time: =>
      @model.get('time')

    toggleUpvote: (e) =>
      @model.upvoteToggle()

    showX: (e) =>
      e.preventDefault()
      if @model.userHasUpvoted()
        @ui.upvotesIcon.addClass('icon-remove')
        @ui.upvotesIcon.removeClass('icon-ok')

    hideX: (e) =>
      e.preventDefault()
      if @model.userHasUpvoted()
        @ui.upvotesIcon.removeClass('icon-remove')
        @ui.upvotesIcon.addClass('icon-ok')

    modelEvents:
      'change:upvotes': 'refreshUpvotes'
      'change:have_i_upvoted': 'refreshUpvoted'

    refreshUpvotes: (event) =>
      @$('.upvote-counter').html event.upvotes()

    refreshUpvoted: (event) =>
      if event.userHasUpvoted()
        @ui.upvotesIcon.removeClass('icon-caret-up')
        @ui.upvotesIcon.addClass('icon-ok')
      else
        @ui.upvotesIcon.addClass('icon-caret-up')
        @ui.upvotesIcon.removeClass('icon-ok')
        @ui.upvotesIcon.removeClass('icon-remove')

    refreshUpvoteAllowed: (event) =>
      if event.get('upvote_allowed')
        @ui.upvotesContainer.tooltip 'destroy'
      else
        @ui.upvotesContainer.tooltip
          title: 'Login to upvote.'

    onRender: =>
      @refreshUpvotes @model
      @refreshUpvoted @model
      @refreshUpvoteAllowed @model
