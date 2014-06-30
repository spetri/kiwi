# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :education_subkast, class: Subkast do
    code "EDU"
    name "Education"
    url "education"
  end

  factory :sports_subkast, class: Subkast do
    code "SE"
    name "Sports"
    url "sports"
  end

  factory :movies_subkast, class: Subkast do
    code "TVM"
    name "Movies"
    url "movies"
  end
end
