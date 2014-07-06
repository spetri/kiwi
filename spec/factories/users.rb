FactoryGirl.define do
  sequence :email do |n|
    "user_#{n}@example.com"
  end

  sequence :username do |n|
    "user_#{n}"
  end

  factory :user do
    username
    email
    name "Mr. X" 
    password "secret1234"
    country "CA"
    receive_comment_notifications true
  end
end
