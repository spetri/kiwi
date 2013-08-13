json.array!(@events) do |event|
  json.extract! event, :details, :name, :created_at, :user
  json.set! '_id', event._id.to_s 
  json.set! :date, event.datetime
  json.set! :datetime, event.datetime.utc if event.datetime != nil
end
