class ReminderMailer < ActionMailer::Base
  default from: "from@example.com"

  def welcome
    @user = User.first
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end

  def reminder(reminder)
   @reminder = reminder
   @event = reminder.event
   @user = reminder.user
   mail(to: @user.email, subject: "Reminder: #{@event.name}")
  end
end
