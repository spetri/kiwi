reminder = @reminder if reminder.nil?
json.extract! reminder, :time_to_event, :time_offset
json.set! '_id', reminder._id.to_s
json.set! :event_id, reminder.event.id.to_s
json.set! :user_id, reminder.user.id.to_s
