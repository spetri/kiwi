json.extract! @event, :details, :name, :created_at, :updated_at, :local_time, :tv_time, :is_all_day, :time_format, :description
json.set! :date, @event.datetime
json.set! :datetime, @event.datetime.utc if @event.datetime != nil
json.set! :mediumUrl, @event.image.url(:medium)
json.set! :thumbUrl, @event.image.url(:thumb)
