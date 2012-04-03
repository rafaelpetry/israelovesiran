require './app'
require 'test/unit'
require 'rack/test'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_root_should_present_the_submit_form
    get '/'
    assert last_response.ok?
    assert_match /Share your image with the world/, last_response.body
  end

  def test_upload_should_redirect_back_to_root_without_photo
    post '/upload', photo: nil
    follow_redirect!

    assert_equal "http://example.org/", last_request.url
    assert last_response.ok?
  end

  def test_upload_should_redirect_back_to_root_without_tempfile
    post '/upload', photo: { tempfile: nil }
    follow_redirect!

    assert_equal "http://example.org/", last_request.url
    assert last_response.ok?
  end

end