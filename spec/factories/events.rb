FactoryGirl.define do 
  sequence :name do |n|
    "event #{n}"
  end

  factory :event do 
    before (:create) do
      Timecop.freeze(Time.local(2014, 1, 24, 12, 00, 00))
    end

    after (:create) do
      Timecop.return
    end 

    name
    datetime 1.day.from_now
    upvote_names []
    country "CA"
    location_type "national"
    subkast "ST"
    is_all_day false
    time_format ''

    trait :with_2_upvotes do
      upvote_names ["eventlover1", "eventlover2"]
    end

    trait :with_5_upvotes do
      upvote_names ["eventlover1", "eventlover2", "eventlover3", "eventlover4", "eventlover5"]
    end

    trait :with_7_upvotes do
      upvote_names ["eventlover1", "eventlover2", "eventlover3", "eventlover4", "eventlover5", "eventlover6", "eventlover7"]
    end

    trait :in_1_day do
      datetime 1.day.from_now - 1.second
      local_date 1.day.from_now.to_date
    end

    trait :in_2_days do
      datetime 2.day.from_now - 1.second
      local_date 2.day.from_now.to_date
    end

    trait :in_3_days do
      datetime 3.day.from_now - 1.second
      local_date 3.day.from_now.to_date
    end

    trait :in_4_days do
      datetime 4.day.from_now - 1.second
      local_date 4.day.from_now.to_date
    end

    trait :in_5_days do
      datetime 5.day.from_now - 1.second
      local_date 5.day.from_now.to_date
    end

    trait :in_6_days do
      datetime 6.day.from_now - 1.second
      local_date 6.day.from_now.to_date
    end

    trait :in_1_week do
      datetime 1.week.from_now - 1.second
      local_date 1.week.from_now.to_date
    end

    trait :in_2_weeks do
      datetime 2.week.from_now - 1.second
      local_date 2.week.from_now.to_date
    end

    trait :in_3_weeks do
      datetime 3.week.from_now - 1.second
      local_date 3.week.from_now.to_date
    end

    trait :back_1_week do
      datetime 1.week.ago
      local_date 1.week.ago.to_date
    end

    trait :split_datetime do
      datetime 5.week.from_now - 8.hour
      local_date 5.week.from_now
    end

    trait :all_day do
      is_all_day true
    end

    trait :international do
      location_type "international"
    end

    trait :recurring do
      time_format "recurring"
    end

    trait :tv_show do
      time_format "tv_show"
    end
  end
end
