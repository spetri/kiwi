module Paperclip
  class Cropper < Thumbnail
    def transformation_command
      crop_command + super
    end

    def crop_command
      target = @attachment.instance
      [" -crop '#{target.width.to_i}x#{target.height.to_i}+#{target.crop_x.to_i}+#{target.crop_y.to_i}'"]
    end
  end
end
