class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  field :details, type: String
  field :name, type: String
  field :user, type: String
  field :datetime, type: DateTime
  field :width, type: Integer
  field :height, type: Integer
  field :crop_x, type: Integer
  field :crop_y, type: Integer
  

  has_mongoid_attached_file :image, :styles => 
    {
      :thumb => "80x60>",
      :medium => "400x300>"
    },
    :processors => [:cropper]
end
