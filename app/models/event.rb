class Event
  include Mongoid::Document
  field :details, type: String
  field :title, type: String
end
