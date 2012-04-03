require 'flickraw'

module Sharing
  class Flickr
    def initialize(api_key, secret, access_token, access_secret)
      FlickRaw.api_key = api_key
      FlickRaw.shared_secret = secret
      @access_token = access_token
      @access_secret = access_secret
    end

    def upload(file_name)
      client.upload_photo file_name, :is_public => false, :tags => 'weloveiran'
    end

    def photo_url(photo_id)
      info = client.photos.getInfo(:photo_id => photo_id)
      FlickRaw.url_b(info)
    end

    private

    def client
      unless @client
        @client ||= FlickRaw::Flickr.new
        @client.access_token = @access_token
        @client.access_secret = @access_secret
      end
      @client
    end
  end
end
