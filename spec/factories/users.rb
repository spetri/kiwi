FactoryGirl.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :username do |n|
    "user_#{n}"
  end

  factory :user do
    username
    email
    name "Mr. X" 
    password "secret1234"
  end
end
