require 'net/http'
require 'uri'

module Sinatra
  module UrlHelper

    def tiny_url(long_url)
      get_response_url "http://tinyurl.com/api-create.php?url=#{URI.escape(long_url)}"
    end

    private

    def get_response_url(url)
      Net::HTTP.get_response(URI.parse(url).host, url).body
    end
  end

  helpers UrlHelper
end
