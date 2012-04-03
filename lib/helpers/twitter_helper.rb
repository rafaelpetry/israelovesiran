module Sinatra
  module TwitterHelper

    def share_to_twitter_url(photo_url)
      "https://twitter.com/intent/tweet?source=webclient&text=#{twitter_message(photo_url)}"
    end

    private

    def twitter_message(photo_url)
      URI.escape("Iranians, we will never bomb your country. We love you. #{tinyUrl(photo_url)} #israeloveiran")
    end
  end

  helpers TwitterHelper
end
