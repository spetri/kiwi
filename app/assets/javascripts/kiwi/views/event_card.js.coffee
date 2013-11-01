FK.App.module "Events.EventPage", (EventPage, App, Backbone, Marionette, $, _) ->

    class EventPage.EventCard extends Marionette.ItemView
      template: FK.Template('event_card')
      className: 'event-card'

      events:
        'click .event-upvotes': 'upvoteToggle'

      upvoteToggle: =>
        @model.upvoteToggle()

      modelEvents:
        'change:upvotes': 'refreshUpvotes'
        'change:haveIUpvoted': 'upvotedTooltip'
        'change:mediumUrl': 'render'

      refreshUpvotes: (event) =>
        @$('.upvote-counter').html event.upvotes()

      upvotedTooltip: (event) =>
        if event.userHasUpvoted()
          @$('.event-upvotes').tooltip
            title: 'You have upvoted.'
        else
          @$('.event-upvotes').tooltip 'destroy'

      onRender: =>
        @refreshUpvotes(@model)
  
