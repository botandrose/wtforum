require "uri"
require "active_support/core_ext/object"
require "mechanize"
require "nokogiri"

require "wtforum/user"
require "wtforum/session"

class WTForum
  class WTForumError < StandardError; end

  def self.extract_value key, options
    xml = Nokogiri::XML.parse(options[:from])
    node = xml.css(key.to_s)
    if node.present?
      node.text
    else
      raise WTForumError, xml.css("errormessage, error, .errorMsg").text
    end
  end

  attr_accessor :domain, :api_key, :admin_username, :admin_password

  def initialize credentials
    credentials.each do |key, value|
      self.send :"#{key}=", value
    end
  end

  def create_session_uri user_id
    uri = base_api_uri(userid: user_id)
    uri.path = "/register/setauthtoken"
    uri
  end

  def create_user_uri attributes
    uri = base_api_uri(attributes)
    uri.path = "/register/create_account"
    uri
  end

  def find_user_uri user_id
    uri path: "/register/register", query: "edit=1&userid=#{user_id}"
  end

  def find_user_by_username_uri username
    uri path: "/register", query: "action=members&search=true&s_username=#{username}"
  end

  def edit_uri user_id
    find_user_uri(user_id)
  end

  def edit_user_username_uri user_id
    uri path: "/register/edit_username", query: "userid=#{user_id}"
  end

  def edit_user_email_uri user_id
    uri path: "/register/edit_password", query: "userid=#{user_id}"
  end

  def count_users_uri
    uri path: "/register/members"
  end

  def destroy_user_uri user_id
    uri path: "/register/delete", query: "mem_userid=#{user_id}"
  end

  def authorized_agent
    @authorized_agent ||= begin
      a = agent
      a.get(login_uri)
      a
    end
  end

  def agent
    Mechanize.new
  end

  private

  def base_uri
    URI("http://#{domain}")
  end

  def base_api_uri attributes={}
    attributes[:apikey] = api_key
    uri = base_uri
    uri.query = attributes.to_param
    uri
  end

  def login_uri
    uri path: "/register/dologin", query: "member=#{admin_username}&pw=#{admin_password}&remember=checked"
  end

  def uri attributes
    base_uri.tap do |uri|
      uri.path = attributes[:path]
      uri.query = attributes[:query]
    end
  end
end

