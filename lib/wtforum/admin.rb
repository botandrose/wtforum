class WTForum
  def admin
    Admin.new(username: admin_username, password: admin_password)
  end

  class Admin
    def initialize attributes={}
      self.username = attributes[:username]
      self.password = attributes[:password]
    end

    attr_accessor :username, :password

    def api_key
      page = authorized_agent.get("http://www.websitetoolbox.com/cgi/members/mboard.cgi?action=showmbsettings&tab=Single+Sign+On")
      page.form_with(name: "posts").field_with(name: "apikey").value
    end

    # def create_admin_user attributes
    #   attributes[:email] ||= "#{attributes[:username]}@example.com"

    #   visit "http://www.websitetoolbox.com/tool/members/mb/addusers"
    #   fill_in "member", with: attributes[:username]
    #   fill_in "pw", with: attributes[:password]
    #   fill_in "email", with: attributes[:email]
    #   select "Administrators", from: "usergroupid"
    #   click_button "Register New User"
    # end

    def domain
      page = authorized_agent.get("http://www.websitetoolbox.com/cgi/members/main.cgi")
      page.at(".heading h2 span").text.split("//").last
    end

    def domain= full_domain
      domain_parts = full_domain.split(".")
      subdomain = domain_parts.shift
      domain = domain_parts.join(".")

      page = authorized_agent.get("http://www.websitetoolbox.com/tool/members/domain?tool=mb&action=custom_domain_type&dashboard=1")
      form = page.form_with(action: "domain")
      form.field_with(name: "domain_sub_domain").value = subdomain
      form.field_with(name: "domain").value = domain
      form.submit
    end

    def skin
      page = authorized_agent.get("http://www.websitetoolbox.com/tool/members/mb/skins")
      page.at(".skin_title").text.sub(/[[:space:]]+Customize.+$/m, '')
    end

    def skin= skin_name
      skin_id = skins.fetch(skin_name)
      authorized_agent.get("http://www.websitetoolbox.com/tool/members/mb/skins?action=install_skin&subaction=skins&skin_id=#{skin_id}&search_skin=&sorted=")
    end

    def head_html
      page = authorized_agent.get("http://www.websitetoolbox.com/cgi/members/hf.cgi?tool=mb")
      form = page.form_with(name: "hfform")
      form.field_with(name: "head").value
    end

    def head_html= html
      page = authorized_agent.get("http://www.websitetoolbox.com/cgi/members/hf.cgi?tool=mb")
      form = page.form_with(name: "hfform")
      form.field_with(name: "head").value = html
      form.submit
    end

    private

    def admin_session
      visit "http://www.websitetoolbox.com/tool/members/login"
      fill_in "username", with: course.admin_username
      fill_in "password", with: course.admin_password
      click_button "Login"
    end

    def skins
      {
        "Soft Gray" => 21,
        "Elegance" => 50,
      }
    end

    def authorized_agent
      @authorized_agent ||= begin
        a = agent
        a.post("http://www.websitetoolbox.com/tool/members/login",
          action: "dologin",
          username: username,
          password: password,
        )
        a
      end
    end

    def agent
      Mechanize.new
    end
  end
end
