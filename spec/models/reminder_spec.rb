require 'spec_helper'
describe Reminder do 

  it "should have associations with user and event" do
    reminder = create :reminder
    reminder.status.should == "PENDING"
    reminder.event.should be_kind_of Event
    reminder.user.should be_kind_of User
  end

  context 'determining the time the reminder needs to be sent' do

    let(:fifteen_minutes_before_reminder) { create :reminder, :fifteen_m_before }
    let(:one_hour_before_reminder) { create :reminder, :one_h_before }
    let(:four_hours_before_reminder) { create :reminder, :four_h_before }
    let(:one_day_before_reminder) { create :reminder, :one_d_before }
    let(:tv_show_reminder) { create :tv_show_reminder, :one_h_before }

    it 'should be able to plan a reminder for 15 minutes before' do
      fifteen_minutes_before_reminder.send_at.should ==  Time.utc(2014, 1, 10, 11, 45, 0)
    end

    it 'should be able to plan a reminder for 1 hour before' do
      one_hour_before_reminder.send_at.should == Time.utc(2014, 1, 10, 11, 0, 0)
    end

    it 'should be able to plan a reminder for 4 hours before' do
      four_hours_before_reminder.send_at.should == Time.utc(2014, 1, 10, 8, 0, 0)
    end

    it 'should be able to plan a reminder for 1 day before' do
      one_day_before_reminder.send_at.should == Time.utc(2014, 1, 9, 12, 0, 0)
    end

    it 'should be able to plan a reminder for a non normal time zone event' do
      tv_show_reminder.send_at.should == Time.utc(2014, 2, 14, 21, 0, 0)
    end
  end

  describe 'looking up reminders that need to be sent right now' do
    before(:each) do
      create :reminder, :fifteen_m_before
      create_list :reminder, 4, :one_h_before
      create :reminder, :four_h_before
      Timecop.freeze(Time.utc(2014, 1, 10, 11, 0, 0))
    end

    it 'should be able to lookup all reminders that are due now' do
      Reminder.lookup_reminders_to_send.size.should == 4
    end
  end
end
