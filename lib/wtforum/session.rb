# encoding: utf-8

module WTForum
  class Session
    def self.create user_id
      uri = create_uri(user_id)
      page = Mechanize.new.get(uri)
      auth_token = WTForum.extract_value(:authtoken, from: page.body)
      new(auth_token)
    end

    def initialize token
      @token = token
    end

    attr_reader :token

    private

    def self.create_uri user_id
      uri = WTForum.base_api_uri(userid: user_id)
      uri.path = "/register/setauthtoken"
      uri
    end
  end
end
