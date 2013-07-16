json.array!(@events) do |event|
  json.extract! event, :details, :title
  json.url event_url(event, format: :json)
end
