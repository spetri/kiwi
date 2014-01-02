require 'spec_helper'
require 'date'

describe Event do
  it "should work" do 
    e = Event.new name: "foobar"
    e.save!
    Event.all.size.should == 1
  end

  describe "Event fetching" do
    before(:each) do
      for i in 0..2
        event = create :future_event
        event.save
      end
      for i in 0..1
        event = create :past_event
        event.save
      end
    end

    it "should be able to fetch events by date" do
      Event.get_events_by_date(1.week.from_now).size.should == 3
    end

    it "should be able to limit the number of events fetched by date" do
      Array(Event.get_events_by_date(1.week.from_now, 2)).size.should == 2
    end

    it "should be able to skip a given number of events fetched by date" do
      Array(Event.get_events_by_date(1.week.from_now, 0, 1)).size.should == 2
    end

    it "should be able to skip a given number of events and still limit correctly" do
      Array(Event.get_events_by_date(1.week.from_now, 1, 1)).size.should == 1
    end
  end
end
