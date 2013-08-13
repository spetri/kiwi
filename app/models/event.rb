class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  field :details, type: String
  field :name, type: String
  field :user, type: String
  field :datetime, type: DateTime

end
