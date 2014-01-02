FactoryGirl.define do 
  sequence :name do |n|
    "event #{n}"
  end

  factory :event do 
    name
    factory :future_event do
      datetime 1.week.from_now
    end

    factory :past_event do
      datetime 1.week.ago
    end
  end
end
