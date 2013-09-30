class WTForum
  class User
    class NotFound < StandardError; end
    class UsernameAlreadyTaken < StandardError; end

    def self.create wtforum, response, attributes
      user_id = WTForum.extract_value(:userid, from: response.body)
      attributes[:id] = user_id.to_i
      new(wtforum, attributes)
    end

    def self.update wtforum, user_id, attributes
      wtforum.find_user(user_id).update_attributes!(attributes)
    end

    def self.destroy wtforum, user_id
      wtforum.destroy_user(user_id)
      true
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

