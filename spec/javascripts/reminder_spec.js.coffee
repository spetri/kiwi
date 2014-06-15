describe "Reminder", ->

  it 'should be able to remove a reminder by event, time and user', ->
    eventId = 'abc123'
    @reminders = new FK.Collections.Reminders()
    event = new FK.Models.Event _id: eventId
    user = new FK.Models.User username: 'grayden', _id: { "$oid": 'asdf' }

    @reminders.addReminders(user, event, ['15m', '1h', '6h'])

    @reminders.removeReminders(user, event, ['15m'])
    expect(@reminders.length).toBe(2)
    expect(@reminders.times()).not.toContain('15m')
