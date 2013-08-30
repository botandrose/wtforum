class WTForum
  class Session
    def self.create wtforum, user_id
      response = wtforum.create_session(user_id)
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
  end
end

