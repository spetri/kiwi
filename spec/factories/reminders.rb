FactoryGirl.define do 
  factory :reminder do 
    status "PENDING"
    event { create :future_event }
    user { create :user }
  end
end
