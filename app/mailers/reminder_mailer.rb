class ReminderMailer < ActionMailer::Base
  default from: "from@example.com"

 def welcome
    @user = User.first
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end
end
