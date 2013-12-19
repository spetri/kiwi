class Reminder
  include Mongoid::Document
  include Mongoid::Timestamps
  field :send_at,  :type => Time
  field :status, :type => String 
  belongs_to :user
  belongs_to :event


  def self.send_reminders
    #TODO stuff here
    # test business logic here to see if status = PENDING, and the time is right
    logger.info "SEND REMINDERS!"
    ReminderMailer.welcome.deliver!

  end
end
