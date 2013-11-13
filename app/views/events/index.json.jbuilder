json.array!(@events) do |event|
  json.extract! event, :details, :name, :created_at, :user, :local_time, :tv_time, :is_all_day, :time_format, :description
  json.set! '_id', event._id.to_s
  json.set! :date, event.datetime
  json.set! :datetime, event.datetime.utc if event.datetime != nil
  json.set! :mediumUrl, event.image.url(:medium)
  json.set! :thumbUrl, event.image.url(:thumb)
  if user_signed_in?
    json.set! :have_i_upvoted, event.have_i_upvoted(current_user.email)
  end
  json.set! :upvotes, event.how_many_upvotes()
end
