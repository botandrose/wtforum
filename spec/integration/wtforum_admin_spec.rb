require "spec_helper"

describe WTForum::Admin, vcr: true do
  let(:wtforum_admin) { test_wtforum.admin }

  it "gets api key" do
    wtforum_admin.api_key.should == test_wtforum.api_key
  end

  it "gets and sets domain" do
    old_domain = wtforum_admin.domain
    wtforum_admin.domain = "wtf.complexityexplorer.org"
    wtforum_admin.domain.should == "wtf.complexityexplorer.org"
    wtforum_admin.domain = old_domain
  end

  it "gets and sets skin" do
    old_skin = wtforum_admin.skin
    wtforum_admin.skin = "Elegance"
    wtforum_admin.skin.should == "Elegance"
    wtforum_admin.skin = old_skin
  end

  it "gets and sets head_html" do
    old_head_html = wtforum_admin.head_html
    wtforum_admin.head_html = "<h1>"
    wtforum_admin.head_html.should == "<h1>"
    wtforum_admin.head_html = old_head_html
  end
end

