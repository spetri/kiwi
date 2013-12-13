describe "Reminder", ->

  it 'should be able to remove a reminder by event, time and user', ->
    eventId = 'abc123'
    user = 'grayden'
    @reminders = new FK.Collections.Reminders()

    reminders = _.map ['15m', '1h', '24h'], (time) ->
      {event: eventId, user: user, time_to_event: time}

    @reminders.add reminders

    @reminders.removeReminder(user, '15m', eventId)
    expect(@reminders.length).toBe(2)
    expect(@reminders.times()).not.toContain('15m')
