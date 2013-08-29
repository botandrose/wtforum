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

  def base_uri
    URI("http://#{domain}")
  end

  def base_api_uri attributes={}
    attributes[:apikey] = api_key
    uri = base_uri
    uri.query = attributes.to_param
    uri
  end
end

