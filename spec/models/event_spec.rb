require 'spec_helper'
require 'date'

describe Event do
  it "should work" do 
    e = Event.new name: "foobar"
    e.save!
    Event.all.size.should == 1
  end

  describe "Event fetching" do
    describe "by date" do
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

    describe "by top ranked" do
      before(:each) do
        for i in 0..3
          event = create :event
          event.save!
        end

        upvoted_event = create :upvoted_event
        upvoted_event.save

        many_upvoted_event = create :many_upvoted_event
        many_upvoted_event.save

        @topRanked = Array(Event.top_ranked(4))
      end
      it "should be able to get an arbitrary number of the top ranked events" do
        @topRanked.size.should == 4
      end

      it "should be able to get the highest number of upvotes first" do
        @topRanked[0].upvote_names.size.should == 5
        @topRanked[1].upvote_names.size.should == 2
      end
    end

    describe "starting package" do
      before(:each) do
        for i in 0..2
          event = create :upvoted_further_future_event
          event.save
        end
        for i in 0..2
          event = create :many_upvoted_future_event
          event.save
        end
        for i in 0..2
          event = create :many_upvoted_further_future_event
          event.save
        end

        event = create :future_event
        event.save

        event = create :past_event
        event.save

        event = create :highly_upvoted_event
        event.save
      end
      it "should be able to get a total total number of events across days" do
        events = Event.get_enough_events_from_day(Date.today(), 5, 3)
        Array(events).size.should == 6
      end

      it "should be able to find the date of the latest event" do
        date = Event.get_last_date()
        date.should === 3.week.from_now.to_date
      end

      it "should be able to get the first 6 events and top 5 without overlap" do
        events = Event.get_starting_events(Date.today(), 6, 3, 5)
        events.size.should == 7
      end
    end
  end
end
