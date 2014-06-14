class FK.Models.Reminder extends Backbone.GSModel
  idAttribute: "_id"

  defaults:
    time_to_event: ''
    user: ''
    event: ''

class FK.Collections.Reminders extends Backbone.Collection
  model: FK.Models.Reminder
  url: '/reminders'

  addReminders: (user, event, timesToEvent) =>
    reminders = _.map(timesToEvent, (timeToEvent) =>
        user_id: user.userId()
        event_id: event.get('_id')
        time_to_event: timeToEvent
        recipient_time_zone: jstz.determine().name()
    )

    _.each(reminders, (reminder) =>
      @create reminder if not @findReminder(user, event, reminder.time_to_event)
    )

  removeReminders: (user, event, timesToEvent) ->
    _.each(timesToEvent, (timeToEvent) =>
      reminder = @findReminder(user, event, timeToEvent)
      reminder.destroy() if reminder
    )

  findReminder: (user, event, timeToEvent) =>
    @findWhere
      user_id: user.userId()
      time_to_event: timeToEvent
      event_id: event.get('_id')

  fetchForUserAndEvent: (user, event) =>
    @fetch
      data:
        user_id: user.userId()
        event_id: event.get('_id')
      success: () =>
        @trigger 'fetched'
      
  times: () =>
    @pluck 'time_to_event'
