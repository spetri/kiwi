FactoryGirl.define do 
  sequence :name do |n|
    "event #{n}"
  end

  factory :event do 
    name

    factory :upvoted_event do
      upvote_names ["eventlover1", "eventlover2"]
    end

    factory :many_upvoted_event do
      upvote_names ["eventlover1", "eventlover2", "eventlover3", "eventlover4", "eventlover5"]
    end

    factory :future_event do
      datetime 1.week.from_now
    end

    factory :past_event do
      datetime 1.week.ago
    end
  end
end
