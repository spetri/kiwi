FactoryGirl.define do 
  factory :event do 
    name "Great event"
    factory :future_event do
      datetime 1.week.from_now
    end
  end
end
