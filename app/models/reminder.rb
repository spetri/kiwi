class Reminder
  include Mongoid::Document
  include Mongoid::Timestamps
  field :send_at,  :type => Time
  field :status, :type => String 
  belongs_to :user
  belongs_to :event
end
