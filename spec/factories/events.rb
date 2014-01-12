FactoryGirl.define do 
  sequence :name do |n|
    "event #{n}"
  end

  factory :event do 
    name
    datetime 1.day.from_now
    upvote_names []

    trait :with_2_upvotes do
      upvote_names ["eventlover1", "eventlover2"]
    end

    trait :with_5_upvotes do
      upvote_names ["eventlover1", "eventlover2", "eventlover3", "eventlover4", "eventlover5"]
    end

    trait :with_7_upvotes do
      upvote_names ["eventlover1", "eventlover2", "eventlover3", "eventlover4", "eventlover5", "eventlover6", "eventlover7"]
    end

    trait :in_1_week do
      datetime 1.week.from_now
    end

    trait :in_2_weeks do
      datetime 2.week.from_now
    end

    trait :in_3_weeks do
      datetime 3.week.from_now
    end

    trait :back_1_week do
      datetime 1.week.ago
    end
  end
end
