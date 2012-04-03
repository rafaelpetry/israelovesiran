require 'net/http'
require 'uri'

module Sinatra
  module UrlHelper

    def get_response_url(url)
      Net::HTTP.get_response(URI.parse(url).host, url).body
    end

    def tinyUrl(long_url)
      get_response_url "http://tinyurl.com/api-create.php?url=#{URI.escape(long_url)}"
    end
  end

  helpers UrlHelper
end
