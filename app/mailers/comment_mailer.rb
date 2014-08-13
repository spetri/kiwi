class CommentMailer < ActionMailer::Base
  default from: "Forekast <hello@forekast.com>"
  
  def send_notifications(comment)
    event_owner = User.where(username: comment.event.user).first

    if comment.reply?
      reply_notice(comment, comment.parent_author).deliver! if comment.parent_author.receive_comment_notifications
    end

    unless (comment.parent.present? and comment.parent.authored_by == event_owner) or comment.authored_by == event_owner
      comment_notice(comment, event_owner).deliver! if event_owner.receive_comment_notifications
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
