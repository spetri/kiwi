require 'spec_helper'

describe Event do
  it "should work" do 
    e = Event.new name: "foobar"
    e.save!
    Event.all.size.should == 1
  end
end
