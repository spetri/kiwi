class Comment < ActionMailer::Base
  default from: "from@example.com"

  def comment_notice(comment, recipient)
    @comment = comment
    mail(to: recipient.email, subject: "#{comment.authored_by.username} commented on your event")
  end

  def reply_noticy(comment, recipient)
    @comment = comment
    mail(to: recipient.email, subject: "#{comment.authored_by.username} replied to your comment")
  end
end
