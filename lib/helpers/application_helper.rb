require 'sharing/facebook'
require 'sharing/flickr'

module Sinatra
  module ApplicationHelper

    def facebook_callback_url(photo_id)
      'http://' + request.host_with_port + '/callback/facebook/' + photo_id
    end

    def share_to_tumblr_url(photo_url)
      "http://www.tumblr.com/share/photo?source=#{CGI.escape(photo_url)}" +
        "&caption=#{URI.escape("We Love Iran")}" +
        "&click_thru=#{CGI.escape(request.url)}"
    end

    def facebook
      @facebook_sharing ||= Sharing::Facebook.new(settings.fb_app_id, settings.fb_app_secret)
    end

    def flickr
      @flickr_sharing ||= Sharing::Flickr.new(settings.flickr_api_key, settings.flickr_secret, settings.flickr_access_token, settings.flickr_access_secret)
    end
  end

  helpers ApplicationHelper
end
