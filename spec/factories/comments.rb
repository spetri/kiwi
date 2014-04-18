FactoryGirl.define do
  factory :comment do
    event
    factory :flagged_comment do
      flagged_by { [build(:user) , build(:user) ] }
      factory :deleted_comment do 
        deleted_by { create(:user) }
      end
      factory :hidden_comment do 
        hidden_by { create(:user) }
      end
    end
  end
end
