require 'fb_graph'

module Sharing
  class Facebook
    def initialize(app_id, app_secret)
      @app_id = app_id
      @app_secret = app_secret
    end

    def authorization_url(callback_url)
      client.redirect_uri = callback_url
      client.authorization_uri(:scope => [:publish_stream, :publish_actions])
    end

    def share_photo(photo_url, message, auth_code, callback_url)
      client.redirect_uri = callback_url
      client.authorization_code = auth_code
      token = client.access_token! :client_auth_body

      user = FbGraph::User.me(token)
      user.photo!(:url => photo_url, :message => message)
    end

    private

    def client
      @client ||= FbGraph::Auth.new(@app_id, @app_secret).client
    end
  end
end
