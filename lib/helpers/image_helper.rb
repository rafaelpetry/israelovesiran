require 'sinatra/base'
require 'RMagick'

module Sinatra
  module ImageHelper
    MAXIMUM_SIZE = 500

    def add_logo(image_path, color_scheme)
      logo = logo_in(color_scheme)

      original_image = Magick::Image::read(image_path)[0]
      user_img = original_image.resize_to_fit(MAXIMUM_SIZE, MAXIMUM_SIZE)

      weloveiran_img = Magick::Image::read(logo)[0]
      weloveiran_img = resize(user_img, weloveiran_img)

      images = Magick::ImageList.new
      images << user_img
      images << weloveiran_img

      position_logo!(images)

      images.flatten_images
    end

    def is_an_image?(photo)
      photo && (photo[:type] =~ /image\/.+/)
    end

    private
    def resize(image, banner)
      max_size = image.columns
      max_size *= 0.3 if round?(banner) || landscape?(image)

      banner.resize_to_fit!(max_size)
    end

    def logo_in(color_scheme)
      "static/images/banners/#{color_scheme}.png"
    end

    def position_logo!(images)
      x = images[0].columns - images[1].columns
      y = images[0].rows - images[1].rows

      images[1].page = Magick::Rectangle.new(images[1].columns, images[1].rows, x, y)
      images
    end

    def round?(banner)
      banner.filename =~ /round\.png/
    end

    def landscape?(image)
      image.columns > image.rows
    end
  end

  helpers ImageHelper
end
