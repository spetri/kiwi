class FK.Models.Reminder extends Backbone.GSModel
  idAttribute: "_id"

  defaults:
    time_to_event: ''
    user: ''
    event: ''

class FK.Collections.Reminders extends Backbone.Collection
  model: FK.Models.Reminder
  url: '/reminders'

  addReminders: (user, event, times_to_event) =>
    reminders = _.map(times_to_event, (time_to_event) =>
        user_id: user.user_id()
        event_id: event.get('_id')
        time_to_event: time_to_event
        time_offset: moment().zone()
    )

    _.each(reminders, (reminder) =>
      @create reminder
    )

  removeReminder: (user, timeToEvent, event) ->
    reminder = @findWhere
      user: user
      time_to_event: timeToEvent
      event: event

    @remove reminder

  fetchForUserAndEvent: (user, event) =>
    @fetch
      data:
        user_id: user.user_id()
        event_id: event.get('_id')
      
  times: () =>
    @pluck 'time_to_event'
