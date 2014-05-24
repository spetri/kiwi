FK.App.module "Events.EventPage", (EventPage, App, Backbone, Marionette, $, _) ->

    class EventPage.EventCard extends Marionette.ItemView
      template: FK.Template('event_card')
      className: 'event-card row'

      templateHelpers: () =>
        return {
          prettyDateTime: () => @model.escape('datetimeAsString')
          editAllowed: () => @model.editAllowed()
          description: () => @model.descriptionParsed()
        }

      ui:
        upvotesIcon: '#upvotes-icon'

      triggers:
        'click [data-action="edit"]': 'click:edit'
        'click [data-tool="reminders"] .event-tool': 'click:reminders'

      events:
        'click .event-upvotes': 'upvoteToggle'
        'click [data-action="destroy"]': 'destroy'

      upvoteToggle: =>
        @model.upvoteToggle()

      destroy: =>
        @model.destroy()

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
