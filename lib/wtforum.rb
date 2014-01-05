require "uri"
require "active_support/core_ext/object"
require "mechanize"
require "nokogiri"

require "wtforum/user"
require "wtforum/session"
require "wtforum/admin"

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

  def create_session user_id
    uri = base_api_uri(userid: user_id)
    uri.path = "/register/setauthtoken"
    response = agent.get uri
    Session.create self, response
  end

  def create_user attributes
    keep_trying = attributes.has_key?(:retry) ? attributes.delete(:retry) : true
    original_name = attributes[:username]

    defaults = { pw: Digest::MD5.hexdigest(attributes.to_s) }
    attributes[:member] ||= attributes.delete(:username)
    attributes[:field276177] ||= attributes.delete(:gender)
    attributes[:field276178] ||= attributes.delete(:location)
    attributes[:field276179] ||= attributes.delete(:about)
    attributes.reverse_merge! defaults

    begin
      uri = base_api_uri(attributes)
      uri.path = "/register/create_account"
      response = agent.get uri
      User.create self, response, attributes

    rescue WTForum::WTForumError => e
      if e.message =~ /^Error: The username "(.+?)" has already been taken\.$/
        if keep_trying
          index = attributes[:member].sub(original_name,"").to_i
          new_username = "#{original_name}#{index+1}"
          attributes[:member] = new_username
          retry
        else
          raise User::UsernameAlreadyTaken.new(e.message)
        end
      elsif e.message =~ /Error: It looks like you are already registered as "(.+?)" with that email address./
        find_user_by_username($1)
      else
        raise
      end
    end
  end

  def find_user user_id
    response = authorized_agent.get uri(path: "/register/register", query: "edit=1&userid=#{user_id}")
    raise User::NotFound if response.body.include?("Error: The specified account was not found")

    body = Nokogiri::HTML.parse(response.body)
    attributes = {
      id: user_id,
      member: body.css(".tables td:contains('Username:') + td input").first["value"],
      email: body.css(".tables td:contains('Email Address:') + td").first.text.split(" - ").first,
      name: body.css(".tables td:contains('Full Name:') + td input").first["value"],
      field276177: body.css(".tables select[name='field276177'] option[selected]").first.try(:text).try(:strip),
      field276178: body.css(".tables input[name='field276178']").first.try(:[], "value"),
      field276179: body.css(".tables textarea[name='field276179']").first.try(:text)
    }
    User.new(self, attributes)
  end

  def find_user_by_username username
    response = authorized_agent.get uri(path: "/register", query: "action=members&search=true&s_username=#{username}")
    body = Nokogiri::HTML.parse(response.body)

    # scrape markup: <a href="/profile/1234567" title="View profile">username\t\n</a>
    # search returns partial matches :( so find the exact match.
    # hopefully there aren't more than 50 matches!
    link = body.css("a[title='View profile']:contains('#{username}')").find do |a|
      a.text.strip == username
    end

    link or raise User::NotFound

    id = link["href"].split("/").last
    find_user(id)
  end

  def edit_user user_id
    response = authorized_agent.get uri(path: "/register/register", query: "edit=1&userid=#{user_id}")
  end

  def edit_user_username user_id
    authorized_agent.get uri(path: "/register/edit_username", query: "userid=#{user_id}")
  end

  def edit_user_email user_id
    authorized_agent.get uri(path: "/register/edit_password", query: "userid=#{user_id}")
  end

  def count_users
    response = agent.get uri(path: "/register/members")
    count = response.body.match(/Members\s+\(([\d,]+)\)/m)[1]
    count.gsub(",", "").to_i
  end

  def destroy_user user_id
    authorized_agent.get uri(path: "/register/delete", query: "mem_userid=#{user_id}")
  end

  private

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

