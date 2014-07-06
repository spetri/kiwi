FactoryGirl.define do 
  before(:create) do
    Timecop.freeze(Time.utc(2014, 1, 10, 12, 0, 0))
  end

  factory :reminder do 
    event { create :event, datetime: Time.utc(2014, 1, 10, 12, 0, 0) }
    user { create :user }
    recipient_time_zone "America/New_York"

    factory :tv_show_reminder do
      event { create :event, time_format: 'tv_show', local_time: '5:00 PM', local_date: Date.new(2014, 2, 14) }
    end

    trait :fifteen_m_before do
      time_to_event '15m'
    end

    trait :one_h_before do
      time_to_event '1h'
    end

    trait :four_h_before do
      time_to_event '4h'
    end

    trait :one_d_before do
      time_to_event '1d'
    end
  end
end
