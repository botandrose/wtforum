class WTForum
  class Session
    def self.create wtforum, user_id
      uri = create_uri(wtforum, user_id)
      page = Mechanize.new.get(uri)
      auth_token = WTForum.extract_value(:authtoken, from: page.body)
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

    private

    def self.create_uri wtforum, user_id
      uri = wtforum.base_api_uri(userid: user_id)
      uri.path = "/register/setauthtoken"
      uri
    end
  end
end

