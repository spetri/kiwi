FactoryGirl.define do 
  factory :reminder do 
    status "PENDING"
    event { create :event }
    user { create :user }
  end
end
