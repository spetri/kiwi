require 'open-uri'

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
  field :url, type: String
  field :is_all_day, type: Boolean
  field :time_format, type: String
  field :tv_time , type: String
  field :creation_timezone, type: String
  field :local_time, type: String
  field :description, type: String


  has_mongoid_attached_file :image, :styles =>
    {
      :thumb => "80x60>",
      :medium => "400x300>"
    },
    :processors => [:cropper]


  def image_from_url(url)
    if url && File.exist?(url)
      self.image = open(url)
    else
      self.image = self.no_image()
    end
  end


  def no_image
    File.open("#{Rails.root}/public/images/thumb/missing.png")
  end
end
