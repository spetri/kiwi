class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  field :details, type: String
  field :name, type: String
  field :user, type: String
  field :datetime, type: DateTime

  has_mongoid_attached_file :image, :styles => { :medium => "400x300#", :thumb => "80x60#" }

end
