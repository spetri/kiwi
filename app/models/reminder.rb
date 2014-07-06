class Reminder
  include Mongoid::Document
  include Mongoid::Timestamps
  field :send_at,  :type => Time
  field :status, :type => String 
  field :time_to_event, :type => String
  field :recipient_time_zone, :type => String
  belongs_to :user
  belongs_to :event

  STATUS_PENDING = "PENDING"
  STATUS_DELIVERED = "DELIVERED"

  before_create do |reminder|
    reminder.refresh_send_at
    reminder.status = STATUS_PENDING
  end

  def refresh_send_at
    event_time = event.get_utc_datetime(recipient_time_zone)
    self.send_at = event_time - 15.minutes if time_to_event == '15m'
    self.send_at = event_time - 1.hour if time_to_event == '1h'
    self.send_at = event_time - 4.hour if time_to_event == '4h'
    self.send_at = event_time - 1.day if time_to_event == '1d'
  end

  def reminder_time
    return "15 minutes" if time_to_event == '15m'
    return "1 hour" if time_to_event == '1h'
    return "4 hours" if time_to_event == '4h'
    return "1 day" if time_to_event == '1d'
  end

  def self.lookup_reminders_to_send
    start_time = Time.now.utc - 30.seconds
    end_time = Time.now.utc + 30.seconds
    where(status: STATUS_PENDING, :send_at.gt => start_time, :send_at.lt => end_time)
  end

  def self.send_reminders
    count = 0

    reminders_to_send = lookup_reminders_to_send

    logger.info "SEND REMINDERS! (#{reminders_to_send.count})"

    reminders_to_send.each do |reminder|
      ReminderMailer.reminder(reminder).deliver!
      reminder.update_attributes(status: STATUS_DELIVERED)
      count = count + 1
    end

    ::NewRelic::Agent.record_metric('Custom/Reminders/emails_sent', count)
  end
end
