FK.App.module "Events.EventPage", (EventPage, App, Backbone, Marionette, $, _) ->

    class EventPage.EventCard extends Marionette.ItemView
      template: FK.Template('event_card')
      className: 'event-card row'

      templateHelpers: () =>
        return prettyDate: () => @model.get('datetime').format('dddd, MMM Do, YYYY, h:mm A z')

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
        'change:have_i_upvoted': 'refreshUpvoted'
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

      refreshUpvoteAllowed: (event) =>
        if event.get 'upvote_allowed'
          @$('.event-upvotes').tooltip 'destroy'
        else
          @$('.event-upvotes').tooltip
            title: 'Login to upvote.'

      renderReminderPopover: () =>
        @remindersView = new EventPage.EventReminders
          model: @model
        @$('[data-action="set-reminder"]').popover
          html: true
          placement: 'bottom'
          title: 'Remind me of this event'
          content: @remindersView.render().el
      
      onRender: =>
        @refreshUpvotes(@model)
        @refreshUpvoted(@model)
        @refreshUpvoteAllowed(@model)

        @renderReminderPopover()
        

