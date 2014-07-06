class CommentMailer < ActionMailer::Base
  default from: "from@example.com"
  
  def send_notifications(comment)
    event_owner = User.where(username: comment.event.user).first

    if comment.parent.present?
      reply_notice(comment, comment.parent.authored_by).deliver!
    end

    unless (comment.parent.present? and comment.parent.authored_by == event_owner) or comment.authored_by == event_owner
      comment_notice(comment, event_owner).deliver!
    end
  end

  def comment_notice(comment, recipient)
    @comment = comment
    mail(to: recipient.email, subject: "#{comment.authored_by.username} commented on your event", template_name: "comment_notice")
  end

  def reply_notice(comment, recipient)
    @comment = comment
    mail(to: recipient.email, subject: "#{comment.authored_by.username} replied to your comment", template_name: "reply_notice")
  end
end
