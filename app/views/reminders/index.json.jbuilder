json.array!(@reminders) do |reminder|
  json.partial! "reminder", reminder: reminder
end

