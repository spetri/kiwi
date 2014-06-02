class HipChatNotification
  def self.new_user(user)
    return unless CONFIG['hipchat_notifications_room'].present?
    return unless CONFIG['hipchat_api_token'].present?
    client = HipChat::Client.new(CONFIG['hipchat_api_token'])
    message = "New user joined Forekast: #{user.name} - #{user.email} - #{user.username}"
    client[CONFIG['hipchat_notifications_room']].send('kiwibot', message, :color => 'green')
  end

  def self.new_event(event)
    return unless CONFIG['hipchat_notifications_room'].present?
    return unless CONFIG['hipchat_api_token'].present?
    client = HipChat::Client.new(CONFIG['hipchat_api_token'])
    uri = "http://beta.forekast.com/#events/show/#{event.id}"
    message = "New event posted: #{event.name} - <a href='#{uri}'>#{uri}</a>"
    client[CONFIG['hipchat_notifications_room']].send('kiwibot', message, :color => 'yellow')
  end
end
