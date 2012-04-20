require 'sinatra/base'
require 'mini_magick'

module Sinatra
  module ImageHelper
    MAXIMUM_SIZE = 500

    def add_logo(image_path, color_scheme)
      user_img = MiniMagick::Image.open(image_path)
      user_img.resize "#{MAXIMUM_SIZE}x#{MAXIMUM_SIZE}"
      user_img.auto_orient

      banner_path = logo_in(color_scheme)
      weloveiran_img = MiniMagick::Image.open(banner_path)
      resize(user_img, weloveiran_img, banner_path)

      result = user_img.composite(weloveiran_img) do |c|
        c.gravity gravity(user_img, banner_path)
      end

      result
    end

    def is_an_image?(photo)
      photo && (photo[:type] =~ /image\/.+/)
    end

    private
    def logo_in(color_scheme)
      "static/images/banners/#{color_scheme}.png"
    end

    def resize(image, banner, banner_path)
      max_size = image[:width] * 0.8
      max_size *= 0.4 if use_small_logo?(image, banner_path)

      banner.resize "#{max_size}x#{max_size}"
    end

    def use_small_logo?(image, banner_path)
      ratio = image[:width].to_f / image[:height]
      (ratio > 0.85) || round?(banner_path)
    end

    def round?(banner_path)
      !!(banner_path =~ /round\.png/)
    end

    def gravity(image, banner_path)
      return "Southeast" if use_small_logo?(image, banner_path)
      "South"
    end
  end

  helpers ImageHelper
end
