class User
  include Mongoid::Document
  include Mongoid::Timestamps
  field :email, type: String
  field :user, type: String
  field :datetime, type: DateTime

end
