require "spec_helper"

describe WTForum::Session, vcr: true do
  let(:wtforum) { test_wtforum }

  context "when user exists" do
    before do
      begin
        WTForum::User.find_by_username(wtforum, "wtforum_test_user").destroy
      rescue WTForum::User::NotFound; end
    end

    let(:user) do
      WTForum::User.create wtforum, username: "wtforum_test_user", email: "wtforum_test_user@example.com"
    end

    after { user.destroy }

    it "can log in users" do
      session = WTForum::Session.create(wtforum, user.id)
      session.token.should match(/^[a-z0-9]{11}$/i)
    end
  end

  context "when user doesn't exist" do
    it "raises an exception" do
      lambda {
        WTForum::Session.create(wtforum, 1)
      }.should raise_exception(WTForum::User::NotFound)
    end
  end
end

