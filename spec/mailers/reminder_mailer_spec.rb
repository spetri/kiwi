require "spec_helper"

describe ReminderMailer do
  let(:fifteen_minutes_before_reminder) { create :reminder, :fifteen_m_before }
  it 'should send an email' do
    ReminderMailer.reminder(fifteen_minutes_before_reminder).deliver!
    ActionMailer::Base.deliveries.count.should == 1
  end
end
