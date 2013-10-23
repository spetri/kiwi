json.array!(@events) do |event|
  json.extract! event, :details, :name, :created_at, :user, :local_time, :tv_time, :is_all_day, :time_format
  json.set! '_id', event._id.to_s
  json.set! :date, event.datetime
  json.set! :datetime, event.datetime.utc if event.datetime != nil
  json.set! :mediumUrl, event.image.url(:medium)
  json.set! :thumbUrl, event.image.url(:thumb)
end
