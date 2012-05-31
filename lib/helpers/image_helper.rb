require 'sinatra/base'
require 'mini_magick'

module Sinatra
  module ImageHelper
    MAXIMUM_SIZE = 500

    def resize(image_path)
      user_img = MiniMagick::Image.open(image_path)
      user_img.resize "#{MAXIMUM_SIZE}x#{MAXIMUM_SIZE}"
      user_img.auto_orient
      user_img
    end

    def add_logo(user_img, color_scheme)
      banner_path = logo_in(color_scheme)
      weloveiran_img = MiniMagick::Image.open(banner_path)
      resize_banner(user_img, weloveiran_img, banner_path)

      result = user_img.composite(weloveiran_img) do |c|
        c.gravity gravity(user_img, banner_path)
      end

      result
    end

    def is_an_image?(photo)
      photo && (photo[:type] =~ /image\/.+/)
    end

    def max_width_for(width, height, banner_name)
      image = { :width => width, :height => height }
      max_size = define_max_size(image, banner_name)

      { 'width' => max_size, 'gravity' => gravity(image, banner_name).downcase }
    end

    private
    def logo_in(color_scheme)
      "static/images/banners/#{color_scheme}.png"
    end

    def resize_banner(image, banner, banner_path)
      max_size = define_max_size(image, banner_path)
      banner.resize "#{max_size}x#{max_size}"
    end

    def define_max_size(image, banner_path)
      max_size = image[:width] * 0.8
      max_size *= 0.4 if use_small_logo?(image, banner_path)
      max_size
    end

    def use_small_logo?(image, banner_path)
      ratio = image[:width].to_f / image[:height]
      (ratio > 0.85) || round?(banner_path)
    end

    def round?(banner_path)
      !!(banner_path =~ /round/)
    end

    def gravity(image, banner_path)
      return "Southeast" if use_small_logo?(image, banner_path)
      "South"
    end
  end

  helpers ImageHelper
end
