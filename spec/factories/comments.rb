FactoryGirl.define do
  factory :comment do
    message "Wow, events!"
    event
    authored_by { create(:user) }

    factory :flagged_comment do
      flagged_by { [build(:user) , build(:user) ] }
      factory :deleted_comment do
        deleted_by { create(:user) }
      end
      factory :muted_comment do
        muted_by { create(:user) }
      end
    end
  end
end
