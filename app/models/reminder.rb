class Reminder
  include Mongoid::Document
  include Mongoid::Timestamps
  field :reminder_send_at,  :type => Time
  field :reminder_status, :type => String 
  belongs_to :user
  belongs_to :event
end
