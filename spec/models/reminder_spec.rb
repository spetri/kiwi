require 'spec_helper'
require 'pp'
describe Reminder do 

  it "should have associations with user and event" do
    reminder = create :reminder
    reminder.status.should == "PENDING"
    reminder.event.should be_kind_of Event
    reminder.user.should be_kind_of User
  end

end
