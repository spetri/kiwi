class HipChatNotification
  def self.new_user(user)
    return unless self.is_properly_configured?
    client = HipChat::Client.new(CONFIG['hipchat_api_token'])
    message = "New user joined Forekast: #{user.name} - #{user.email} - #{user.username}"
    client[CONFIG['hipchat_notifications_room']].send('kiwibot', message, :color => 'green')
  end

  def self.new_event(event)
    return unless self.is_properly_configured?
    client = HipChat::Client.new(CONFIG['hipchat_api_token'])
    uri = "http://forekast.com/#events/show/#{event.id}"
    message = "New event posted: #{event.name} - <a href='#{uri}'>#{uri}</a>"
    client[CONFIG['hipchat_notifications_room']].send('kiwibot', message, :color => 'yellow')
  end

  def self.new_comment(comment)
    return unless self.is_properly_configured?
    client = HipChat::Client.new(CONFIG['hipchat_api_token'])
    uri = "http://forekast.com/#events/show/#{comment.event.id}"

    if comment.message.size > 30
      comment_message = "#{comment.message[0..29]}..."
    else
      comment_message = comment.message
    end

    message = "New comment posted on event (#{comment.event.name}) - <a href='#{uri}'>#{uri}</a> by #{comment.authored_by.username}: \"#{comment_message}\""
    client[CONFIG['hipchat_comments_notifications_room']].send('kiwibot', message, :color => 'purple')
  end

  def self.is_properly_configured?
    return false unless CONFIG['hipchat_notifications_room'].present?
    return false unless CONFIG['hipchat_comments_notifications_room'].present?
    return false unless CONFIG['hipchat_api_token'].present?
    return false if Rails.env != 'production'
    true
  end
end
