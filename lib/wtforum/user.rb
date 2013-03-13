# encoding: utf-8

require "securerandom"

module WTForum
  class User
    class NotFound < StandardError; end

    def self.create attributes
      defaults = { pw: SecureRandom.hex(10) }
      attributes[:member] ||= attributes.delete(:username)
      attributes.reverse_merge! defaults
      uri = create_uri attributes

      page = agent.get(uri)
      user_id = WTForum.extract_value(:userid, :from => page.body)
      attributes[:id] = user_id.to_i
      new(attributes)
    end

    def self.find user_id
      page = authorized_agent.get(find_uri(user_id))
      raise NotFound if page.body.include?("Error: The specified account was not found")

      body = Nokogiri::HTML.parse(page.body)
      attributes = {
        id: user_id,
        member: body.css(".tables td:contains('Username:') + td input").first["value"],
        email: body.css(".tables td:contains('Email Address:') + td").first.text.split(" - ").first,
      }
      new(attributes)
    end

    def self.update user_id, attributes
      find(user_id).update_attributes!(attributes)
    end

    def self.delete user_id
      authorized_agent.get delete_uri(user_id)
      true
    end

    def self.count
      page = agent.get(count_uri)
      count = page.body.match(/Members \(([\d,]+)\)/)[1]
      count.gsub(",", "").to_i
    end

    def initialize attributes
      self.attributes = attributes
    end

    def update_attributes! attributes
      self.attributes = attributes
      save!
    end

    def save!
      self.class.authorized_agent.get(self.class.edit_username_uri(id)) do |page|
        form = page.forms.first
        form["new_username"] = username
        form.submit
      end
      self.class.authorized_agent.get(self.class.edit_email_uri(id)) do |page|
        form = page.forms.first
        form["email"] = email
        form.submit
      end
    end

    def destroy
      self.class.delete id
    end

    attr_accessor :id, :member, :email
    attr_writer :pw, :apikey

    def username
      member
    end

    def username= value
      self.member = value
    end

    private

    def attributes=(attributes={})
      attributes.each do |key, value|
        send :"#{key}=", value
      end
    end

    def self.agent
      Mechanize.new
    end

    def self.authorized_agent
      @authorized_agent ||= begin
        a = agent
        a.get(login_uri)
        a
      end
    end

    def self.login_uri
      uri = WTForum.base_uri
      uri.path = "/register/dologin"
      uri.query = "member=#{WTForum.admin_username}&pw=#{WTForum.admin_password}&remember=checked"
      uri
    end

    def self.create_uri attributes
      uri = WTForum.base_api_uri(attributes)
      uri.path = "/register/create_account"
      uri
    end

    def self.find_uri user_id
      uri = WTForum.base_uri
      uri.path = "/register/register"
      uri.query = "edit=1&userid=#{user_id}"
      uri
    end

    def self.edit_username_uri user_id
      uri = WTForum.base_uri
      uri.path = "/register/edit_username"
      uri.query = "userid=#{user_id}"
      uri
    end

    def self.edit_email_uri user_id
      uri = WTForum.base_uri
      uri.path = "/register/edit_password"
      uri.query = "userid=#{user_id}"
      uri
    end

    def self.count_uri
      uri = WTForum.base_uri
      uri.path = "/register/members"
      uri
    end

    def self.delete_uri user_id
      uri = WTForum.base_uri
      uri.path = "/register/delete"
      uri.query = "mem_userid=#{user_id}"
      uri
    end
  end
end
