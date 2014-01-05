FactoryGirl.define do 
  sequence :name do |n|
    "event #{n}"
  end

  factory :event do 
    name

    factory :upvoted_event do
      upvote_names ["eventlover1", "eventlover2"]
      factory :upvoted_future_event do
        datetime 1.week.from_now
      end
      factory :upvoted_further_future_event do
        datetime 2.week.from_now
      end
    end

    factory :many_upvoted_event do
      upvote_names ["eventlover1", "eventlover2", "eventlover3", "eventlover4", "eventlover5"]
      factory :many_upvoted_future_event do
        datetime 1.week.from_now
      end
      factory :many_upvoted_further_future_event do
        datetime 2.week.from_now
      end
    end

    factory :highly_upvoted_event do
      upvote_names ["eventlover1", "eventlover2", "eventlover3", "eventlover4", "eventlover5", "eventlover6", "eventlover7"]
      datetime 3.week.from_now
    end

    factory :future_event do
      datetime 1.week.from_now
    end

    factory :past_event do
      datetime 1.week.ago
    end
  end
end
