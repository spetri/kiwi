json.extract! @event, :details, :name, :created_at, :updated_at
json.set! :mediumUrl, @event.image.url(:medium)
json.set! :thumbUrl, @event.image.url(:thumb)
