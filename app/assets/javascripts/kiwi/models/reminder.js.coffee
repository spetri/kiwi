class FK.Models.Reminder extends Backbone.GSModel
  idAttribute: "_id"

  defaults:
    time_to_event: ''
    user: ''
    event: ''

class FK.Collections.Reminders extends Backbone.Collection
  model: FK.Models.Reminder
