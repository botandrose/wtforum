# encoding: utf-8

require "spec_helper"

describe WTForum::Session do
  context "when user exists" do
    let(:user) do
      WTForum::User.create username: "wtforum_test_user", email: "wtforum_test_user@example.com"
    end
    after { user.destroy }

    it "can log in users" do
      session = WTForum::Session.create(user.id)
      session.token.should match(/^[a-z0-9]{11}$/i)
    end
  end

  context "when user doesn't exist" do
    it "raises an exception" do
      lambda {
        WTForum::Session.create(1)
      }.should raise_exception(WTForum::User::NotFound)
    end
  end
end
