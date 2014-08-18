FK.App.module "Events.EventPage", (EventPage, App, Backbone, Marionette, $, _) ->

    class EventPage.EventCard extends Marionette.ItemView
      template: FK.Template('event_card')
      className: 'event-card row'

      templateHelpers: () =>
        return {
          prettyDateTime: () => @model.escape('datetimeAsString')
          myEvent: () => @myEvent()
          moderator: () => @moderatorMode
          description: () => @model.descriptionParsed()
        }

      ui:
        upvotesIcon: '#upvotes-icon'
        remindersContainer: '.reminder-container .sub-container'
        remindersIcon: '.reminder-container .glyphicon'

      triggers:
        'click [data-action="edit"]': 'click:edit'
        'click .reminder-container .glyphicon': 'click:reminders'

      events:
        'click .event-upvotes': 'upvoteToggle'
        'click [data-action="destroy"]': 'prepareDelete'
        'click .btn[data-action="destroy"]': 'destroy'

      upvoteToggle: =>
        @model.upvoteToggle()

      prepareDelete: =>
        @$('[data-action="destroy"]').addClass('btn btn-xs btn-danger')
        @$('[data-action="destroy"]').text('Confirm?')
        _.delay(@resetDelete, 5000)

      destroy: =>
        @model.destroy()

      resetDelete: () =>
        @$('[data-action="destroy"]').removeClass('btn btn-xs btn-danger')
        @refreshDeleteEventText()

      initialize: () =>
        @listenTo @model.remindersCollection(), 'add remove', @refreshReminderHighlight

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

      refreshDeleteEventText: =>
        text ="(Delete event)"
        text = "(Delete my event)" if @myEvent()
        @$('[data-action="destroy"]').text(text)

      refreshReminderHighlight: (model, collection) =>
        if collection.length > 0
          @ui.remindersIcon.addClass('highlight')
        else
          @ui.remindersIcon.removeClass('highlight')

      myEvent: =>
        @username == @model.get('user')

      setUsername: (username) =>
        @username = username

      setModeratorMode: (mode) =>
        @moderatorMode = mode

      onRender: =>
        @refreshUpvotes(@model)
        @refreshUpvoted(@model)
        @refreshUpvoteAllowed(@model)
        @refreshDeleteEventText()
        @refreshReminderHighlight null, @model.remindersCollection()
