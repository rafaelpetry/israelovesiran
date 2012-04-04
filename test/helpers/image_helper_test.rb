require './lib/helpers/image_helper'
require 'test/unit'
require 'mocha'

class ImageHelperTest < Test::Unit::TestCase
  include Sinatra::ImageHelper

  def test_fix_upside_down_orientation
    orientation = [['Orientation', '3']]
    image = mock
    image.stubs(:get_exif_by_entry).with('Orientation').returns(orientation)
    image.expects(:rotate!).with(180)

    fix_orientation!(image)
  end

  def test_fix_left_sideways_orientation
    orientation = [['Orientation', '6']]
    image = mock
    image.stubs(:get_exif_by_entry).with('Orientation').returns(orientation)
    image.expects(:rotate!).with(90)

    fix_orientation!(image)
  end

  def test_fix_right_sideways_orientation
    orientation = [['Orientation', '8']]
    image = mock
    image.stubs(:get_exif_by_entry).with('Orientation').returns(orientation)
    image.expects(:rotate!).with(-90)

    fix_orientation!(image)
  end
end
