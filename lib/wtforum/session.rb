class WTForum
  class Session
    def self.create wtforum, response
      auth_token = WTForum.extract_value(:authtoken, from: response.body)
      new(wtforum, auth_token)
    rescue WTForumError => e
      if e.message == "Error: The specified user does not exist."
        raise WTForum::User::NotFound
      else
        raise
      end
    end

    def initialize wtforum, token
      @wtforum = wtforum
      @token = token
    end

    attr_reader :wtforum, :token

    def auth_token_image_url
      "http://#{wtforum.domain}/register/dologin?authtoken=#{token}"
    end
  end
end

