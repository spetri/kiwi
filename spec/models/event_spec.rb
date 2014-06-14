require 'spec_helper'
require 'date'

describe Event do
  before (:each) do
    Timecop.freeze(Time.local(2014, 1, 24, 12, 00, 00))
  end

  after (:each) do
    Timecop.return
  end

  it "should work" do
    e = Event.new name: "foobar"
    e.save!
    Event.all.size.should == 1
  end

  describe 'datetime getters' do
    let(:all_day_event) { create :event, local_date: Time.local(2014, 1, 24).to_date, is_all_day: true }
    let(:relative_time_event) { create :event, datetime: Time.local(2014, 1, 24, 3, 0, 0) }
    let(:tv_show_event) { create :event, local_date: Time.local(2014, 1, 24).to_date, local_time: '6:00 PM', time_format: 'tv_show' }
    let(:recurring_time_event) { create :event, local_date: Time.local(2014, 1, 24).to_date, local_time: '6:00 PM', time_format: 'recurring' }

    describe 'get utc datetime' do
      it 'should be able to get the utc datetime of an all day event' do
        all_day_event.get_utc_datetime('America/New_York').should == Time.utc(2014, 1, 24, 5, 0, 0)
      end

      it 'should be able to get the utc datetime of a normal time format event' do
        relative_time_event.get_utc_datetime('America/New_York').should == Time.utc(2014, 1, 24, 3, 0, 0)
      end

      it 'should be able to get the utc datetime of a eastern time tv show event' do
        tv_show_event.get_utc_datetime('America/New_York').should == Time.utc(2014, 1, 24, 23, 0, 0)
      end

      it 'should be able to get the utc datetime of a recurring time zone event' do
        recurring_time_event.get_utc_datetime('America/New_York').should == Time.utc(2014, 1, 24, 23, 0, 0)
      end
    end

    describe 'get local datetime' do
      it 'should be able to get the local datetime of an all day event' do
        all_day_event.get_local_datetime('America/New_York').should == Time.local(2014, 1, 24, 0, 0, 0)
      end

      it 'should be able to get the local datetime of a normal time format event' do
        relative_time_event.get_local_datetime('America/New_York').should == Time.local(2014, 1, 23, 22, 0, 0)
      end

      it 'should be able to get the local datetime of an eastern time tv show event' do
        tv_show_event.get_local_datetime("America/Los_Angeles").should == Time.local(2014, 1, 24, 15, 0, 0)
      end

      it 'should be able to get the local datetime of a recurring time zone event' do
        recurring_time_event.get_local_datetime('America/New_York').should == Time.local(2014, 1, 24, 18, 0, 0)
      end
    end
  end

  describe "Event fetching" do
    describe "by date" do
      before(:each) do
        create_list :event, 3, :in_1_week
        create_list :event, 2, :back_1_week
        @testTime = 1.week.from_now - 5.minutes
      end

      it "should be able to fetch events by date" do
        Event.get_events_by_date(@testTime, 300, "CA", ["ST"]).size.should == 3
      end

      it "should be able to limit the number of events fetched by date" do
        Array(Event.get_events_by_date(@testTime, 300, "CA", ["ST"], 2)).size.should == 2
      end

      it "should be able to skip a given number of events fetched by date" do
        Array(Event.get_events_by_date(@testTime, 300, "CA", ["ST"], 0, 1)).size.should == 2
      end

      it "should be able to skip a given number of events and still limit correctly" do
        Array(Event.get_events_by_date(@testTime, 300, "CA", ["ST"], 1, 1)).size.should == 1
      end

      describe "all day events" do
        before(:each) do
          create_list :event, 3, :in_2_weeks, :all_day
          @testTime = 2.weeks.from_now + 2.hours
        end

        it "should be able to get an all day event when its stored datetime falls outside the range requested" do
          Array(Event.get_events_by_date(@testTime, 300, "CA", ["ST"])).size.should == 3
        end
      end

      describe "recurring timezone events" do
        before(:each) do
          create :event, :split_datetime, :recurring
        end
        it "should be able to get recurring timezone events on its local date" do
          Event.get_events_by_date(5.week.from_now, 300, "CA", ["ST"]).size.should == 1
        end
      end

      describe "tv show events" do
        before(:each) do
          create :event, :split_datetime, :tv_show
        end

        it "should be able to get tv show events on its local date" do
          Event.get_events_by_date(5.week.from_now, 300, "CA", ["ST"]).size.should == 1
        end
      end
    end

    describe "sorting" do
      before(:each) do
        create_list :event, 2, :in_1_week, :with_2_upvotes
        create_list :event, 2, :in_1_week, :with_7_upvotes
        create_list :event, 2, :in_1_week, :with_5_upvotes
        @testTime = 1.week.from_now - 5.minutes
      end

      it "should be able to get the events with the most upvotes sorted first" do
        Event.get_events_by_date(@testTime, 300, "CA", ["ST"])[0].upvote_count.should == 7
      end
    end

    describe "by top ranked" do
      before(:each) do
        create_list :event, 2
        create :event, :with_2_upvotes, :back_1_week
        create :event, :with_5_upvotes, :in_1_week

        @topRanked = Array(Event.top_ranked(4, DateTime.now(), 1.week.from_now, 300, "CA", ["ST"]))
      end
      it "should be able to get an arbitrary number of the top ranked events" do
        @topRanked.size.should == 3
      end

      it "should be able to get the highest number of upvotes first" do
        @topRanked[0].upvote_names.size.should == 5
        @topRanked[1].upvote_names.size.should == 0
      end
    end

    describe "starting package" do
      before(:each) do
        create_list :event, 3, :with_2_upvotes, :in_1_week
        create_list :event, 3, :with_5_upvotes, :in_1_week
        create_list :event, 3, :with_5_upvotes, :in_2_weeks

        create :event, :with_5_upvotes, :in_1_week
        create :event, :with_5_upvotes, :back_1_week
        create :event, :with_7_upvotes, :in_1_week
      end
      it "should be able to get a total total number of events across days" do
        events = Event.get_enough_events_from_day(DateTime.now(), 300, "CA", ["ST"], 5, 3)
        Array(events).size.should == 6
      end

      it "should be able to find the date of the latest event" do
        date = Event.get_last_date()
        date.should === 2.week.from_now.to_date
      end

      it "should be able to get the first 6 events and top 5 without overlap" do
        events = Event.get_starting_events(DateTime.now(), 300, "CA", ["ST"], 6, 3, 7)
        events.size.should == 10
      end
    end

    describe "getting enough events" do
      it "should be able to fill up easily when 9 events are selected and there are 3 events per day in the coming 3 days" do
        create_list :event, 3, :in_1_day
        create_list :event, 3, :in_2_days
        create_list :event, 3, :in_3_days
        events = Event.get_enough_events_from_day(DateTime.now(), 300, "CA", ["ST"], 9, 3)
        events.size.should == 9
        dates = events.collect { |event| event.relative_date(300) }
        dates.uniq!
        dates.size.should == 3
      end

      it "should be able to fill up easily when 9 events are selected and there are 3 events per day over the coming 3 days except tomorrow" do
        create_list :event, 3, :in_2_days
        create_list :event, 3, :in_3_days
        create_list :event, 3, :in_4_days
        events = Event.get_enough_events_from_day(DateTime.now(), 300, "CA", ["ST"], 9, 3)
        events.size.should == 9
        dates = events.collect { |event| event.relative_date(300) }
        dates.uniq!
        dates.size.should == 3
      end

      it "should be able to fill up using 5 days where there are not enough events in each day to get to the minimum" do
        create_list :event, 2, :in_1_day
        create_list :event, 2, :in_2_days
        create_list :event, 2, :in_3_days
        create_list :event, 2, :in_4_days
        create_list :event, 2, :in_5_days
        events = Event.get_enough_events_from_day(DateTime.now(), 300, "CA", ["ST"], 9, 3)
        events.size.should == 10
        dates = events.collect { |event| event.relative_date(300) }
        dates.uniq!
        dates.size.should == 5
      end

      it "should not take more than the minimum for each day even if more events are available" do
        create_list :event, 8, :in_1_day
        create_list :event, 3, :in_2_days
        create_list :event, 3, :in_3_days
        events = Event.get_enough_events_from_day(DateTime.now(), 300, "CA", ["ST"], 9, 3)
        events.size.should == 9
        dates = events.collect { |event| event.relative_date(300) }
        dates.uniq!
        dates.size.should == 3
      end

      it "should be able to fill up over an irregular pattern of events on days" do
        create_list :event, 2, :in_1_day
        create_list :event, 1, :in_2_days
        create_list :event, 3, :in_3_days
        create_list :event, 4, :in_4_days
        create_list :event, 7, :in_5_days
        create_list :event, 2, :in_6_days
        events = Event.get_enough_events_from_day(DateTime.now(), 300, "CA", ["ST"], 12, 3)
        events.size.should == 12
        dates = events.collect { |event| event.relative_date(300) }
        dates.uniq!
        dates.size.should == 5
      end
    end

    describe "should be able to get events after a certain date" do
      before(:each) do
        create_list :event, 2, :in_1_week, :with_2_upvotes
        create_list :event, 2, :in_2_weeks, :with_5_upvotes
        create :event, :back_1_week
      end

      it "should be able to get events after a certain date" do
        events = Event.get_events_after_date(DateTime.now() + 3.days, 300, "CA", ["ST"], 3)
        Array(events).size.should == 4
      end

      it "should be able to limit the number of events found after a certain date" do
        events = Event.get_events_after_date(DateTime.now() + 3.days, 300, "CA", ["ST"], 2)
        Array(events).size.should == 2
      end

      it "should be able to get only the earliest dates first" do
        events = Event.get_events_after_date(DateTime.now() + 3.days, 300, "CA", ["ST"], 3)
        events[0].upvote_count.should == 2
      end
    end
  end

  describe "event counting" do
    before(:each) do
      create_list :event, 3, :in_1_week
      create :event, :back_1_week
      create :event, :in_2_weeks
    end

    it "should be able to count events on a day" do
      Event.count_events_by_date(1.week.from_now - 1.minute, 300, "CA", ["ST"]).should == 3
    end
  end

  describe "comment" do
    before(:each) do
      @event = build :event
      @comment1 = build :comment
      @comment2 = build :comment
      @comment1.event = @event
      @comment2.event = @event
      @event.save
      @comment1.save
      @comment2.save
    end

    it "should be able to get the root comments" do
      @event.root_comments.size.should == 2
    end
  end
end
