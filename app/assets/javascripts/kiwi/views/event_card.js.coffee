FK.App.module "Events.EventPage", (EventPage, App, Backbone, Marionette, $, _) ->

    class EventPage.EventCard extends Marionette.ItemView
      template: FK.Template('event_card')
      className: 'event-card'

      ui:
        upvotesIcon: '#upvotes-icon'

      triggers:
        'click [data-action="edit"]': 'click:edit'

      events:
        'click .event-upvotes': 'upvoteToggle'

      upvoteToggle: =>
        @model.upvoteToggle()

      modelEvents:
        'change:upvotes': 'refreshUpvotes'
        'change:haveIUpvoted': 'refreshUpvoted'
        'change:mediumUrl': 'render'

      refreshUpvotes: (event) =>
        @$('.upvote-counter').html event.upvotes()

      refreshUpvoted: (event) =>
        if event.userHasUpvoted()
          @ui.upvotesIcon.removeClass('icon-caret-up')
          @ui.upvotesIcon.addClass('icon-ok')
        else
          @ui.upvotesIcon.addClass('icon-caret-up')
          @ui.upvotesIcon.removeClass('icon-ok')
      
      onRender: =>
        @refreshUpvotes(@model)
        @refreshUpvoted(@model)
  
