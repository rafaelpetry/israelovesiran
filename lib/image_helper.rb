require 'sinatra/base'

module Sinatra
  module ImageHelper
    def add_logo(image_path, logo)
      original_image = Magick::Image::read(image_path)[0]
      user_img = original_image.resize_to_fit(500, 500)

      weloveiran_img = Magick::Image::read(logo)[0]

      weloveiran_img = resize(user_img, weloveiran_img)

      images = Magick::ImageList.new
      images << user_img
      images << weloveiran_img

      max_height = images[0].rows + images[1].rows
      posy = max_height < 500 ? (images[0].rows - images[1].rows) : (500-images[1].rows)

      images[1].page = Magick::Rectangle.new(images[1].columns, images[1].rows, 0, posy)

      images.flatten_images
    end

    def resize(image, banner)
      banner.resize_to_fit!(image.columns)
    end
  end

  helpers ImageHelper
end