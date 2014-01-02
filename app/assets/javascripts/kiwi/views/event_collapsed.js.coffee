FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  class EventList.EventCollapsed extends Backbone.Marionette.ItemView
    template: FK.Template('event_collapsed')
    className: 'event'
    tagName: 'div'

    ui:
      upvotesIcon: '.upvote-container i'

    events:
      'click .upvote-container i': 'toggleUpvote'
      'click .delete': 'deleteClicked'
      'click .event-name': 'triggerEventOpen'

    templateHelpers: =>
     time: =>
      @model.get('time')

     all_day: =>
      return true if @model.get('is_all_day') is '1' or @model.get('is_all_day') is true
      return false

    toggleUpvote: (e) =>
      @model.upvoteToggle()

    deleteClicked: (e) ->
      e.preventDefault()
      @model.destroy()

    triggerEventOpen: (e) ->
      e.preventDefault()
      EventList.trigger 'clicked:open', @model

    modelEvents:
      'change:upvotes': 'refreshUpvotes'
      'change:have_i_upvoted': 'refreshUpvoted'

    refreshUpvotes: (event) =>
      @$('.upvote-counter').html event.upvotes()

    refreshUpvoted: (event) =>
      if event.userHasUpvoted()
        @ui.upvotesIcon.removeClass('icon-caret-up')
        @ui.upvotesIcon.addClass('icon-caret-down')
      else
        @ui.upvotesIcon.addClass('icon-caret-up')
        @ui.upvotesIcon.removeClass('icon-caret-down')

    refreshUpvoteAllowed: (event) =>
      if event.get('upvoted_allowed')
        @ui.upvotesIcon.tooltip 'destroy'
      else
        @ui.upvotesIcon.tooltip
          title: 'Login to upvote.'

    onRender: =>
      @refreshUpvotes @model
      @refreshUpvoted @model
      @refreshUpvoteAllowed @model
