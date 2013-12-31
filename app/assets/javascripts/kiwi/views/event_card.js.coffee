FK.App.module "Events.EventPage", (EventPage, App, Backbone, Marionette, $, _) ->

    class EventPage.EventCard extends Marionette.ItemView
      template: FK.Template('event_card')
      className: 'event-card row'

      templateHelpers: () =>
        return {
          prettyDateTime: () => @model.get('prettyDateTime')
          editAllowed: () => @model.editAllowed()
        }

      ui:
        upvotesIcon: '#upvotes-icon'

      triggers:
        'click': 'click:card'
        'click [data-action="edit"]': 'click:edit'
        'click [data-tool="reminders"] .event-tool': 'click:reminders'

      events:
        'click .event-upvotes': 'upvoteToggle'

      upvoteToggle: =>
        @model.upvoteToggle()

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

      refreshUpvoteAllowed: (event) =>
        if event.get 'upvote_allowed'
          @$('.event-upvotes').tooltip 'destroy'
        else
          @$('.event-upvotes').tooltip
            title: 'Login to upvote.'

      onRender: =>
        @refreshUpvotes(@model)
        @refreshUpvoted(@model)
        @refreshUpvoteAllowed(@model)
