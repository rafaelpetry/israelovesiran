require './lib/helpers/image_helper'
require 'test/unit'
require 'rack/test'
require 'mocha'

class ImageHelperTest < Test::Unit::TestCase
  include Sinatra::ImageHelper

  def test_use_small_logo_if_photo_is_a_square
    square = { :width => 500, :height => 500 }

    assert use_small_logo?(square)
  end

  def test_use_small_logo_if_photo_is_close_to_a_square
    square = { :width => 76, :height => 100 }

    assert use_small_logo?(square)
  end

  def test_use_small_logo_if_photo_is_landscape
    square = { :width => 200, :height => 100 }

    assert use_small_logo?(square)
  end

  def test_use_big_logo_if_photo_is_portrait
    square = { :width => 100, :height => 200 }

    assert_equal false, use_small_logo?(square)
  end
end
