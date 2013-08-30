require "securerandom"

class WTForum
  class User
    class NotFound < StandardError; end

    def self.create wtforum, attributes
      defaults = { pw: SecureRandom.hex(10) }
      attributes[:member] ||= attributes.delete(:username)
      attributes[:field276177] ||= attributes.delete(:gender)
      attributes[:field276178] ||= attributes.delete(:location)
      attributes[:field276179] ||= attributes.delete(:about)
      attributes.reverse_merge! defaults

      response = wtforum.create_user(attributes)
      user_id = WTForum.extract_value(:userid, from: response.body)
      attributes[:id] = user_id.to_i
      new(wtforum, attributes)
    end

    def self.find wtforum, user_id
      response = wtforum.find_user(user_id)
      raise NotFound if response.body.include?("Error: The specified account was not found")

      body = Nokogiri::HTML.parse(response.body)
      attributes = {
        id: user_id,
        member: body.css(".tables td:contains('Username:') + td input").first["value"],
        email: body.css(".tables td:contains('Email Address:') + td").first.text.split(" - ").first,
        name: body.css(".tables td:contains('Full Name:') + td input").first["value"],
        field276177: body.css(".tables select[name='field276177'] option[selected]").first.try(:text).try(:strip),
        field276178: body.css(".tables input[name='field276178']").first["value"],
        field276179: body.css(".tables textarea[name='field276179']").first.text
      }
      new(wtforum, attributes)
    end

    def self.find_by_username wtforum, username
      page = wtforum.find_user_by_username(username)
      body = Nokogiri::HTML.parse(page.body)

      # scrape markup: <a href="/profile/1234567" title="View profile">username\t\n</a>
      # search returns partial matches :( so find the exact match.
      # hopefully there aren't more than 50 matches!
      link = body.css("a[title='View profile']:contains('#{username}')").find do |a|
        a.text.strip == username
      end

      link or raise NotFound

      id = link["href"].split("/").last
      find wtforum, id
    end

    def self.update wtforum, user_id, attributes
      find(wtforum, user_id).update_attributes!(attributes)
    end

    def self.destroy wtforum, user_id
      wtforum.destroy_user(user_id)
      true
    end

    def self.count wtforum
      page = wtforum.count_users
      count = page.body.match(/Members\s+\(([\d,]+)\)/m)[1]
      count.gsub(",", "").to_i
    end

    def initialize wtforum, attributes
      self.wtforum = wtforum
      self.attributes = attributes
    end

    def update_attributes! attributes
      self.attributes = attributes
      save!
    end

    def save!
      wtforum.edit_user(id).tap do |page|
        form = page.forms.first
        form["name"] = name
        form["field276177"] = field276177
        form["field276178"] = field276178
        form["field276179"] = field276179
        form.submit
      end
      wtforum.edit_user_username(id).tap do |page|
        form = page.forms.first
        form["new_username"] = username
        form.submit
      end
      wtforum.edit_user_email(id).tap do |page|
        form = page.forms.first
        form["email"] = email
        form.submit
      end
    end

    def destroy
      self.class.destroy self.wtforum, id
    end

    attr_accessor :wtforum, :id, :member, :email, :name, :field276177, :field276178, :field276179
    attr_writer :pw, :apikey

    def username
      member
    end

    def username= value
      self.member = value
    end

    def gender
      field276177
    end

    def gender= value
      self.field276177 = value
    end

    def location
      field276178
    end

    def location= value
      self.field276178 = value
    end

    def about
      field276179
    end

    def about= value
      self.field276179 = value
    end

    private

    def attributes=(attributes={})
      attributes.each do |key, value|
        send :"#{key}=", value
      end
    end
  end
end

