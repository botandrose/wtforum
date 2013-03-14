# encoding: utf-8

require "spec_helper"

describe WTForum::User do
  it "can CRUD users" do
    begin
      user = nil

      lambda {
        user = WTForum::User.create username: "wtforum_test_user", email: "wtforum_test_user@example.com"
      }.should change(WTForum::User, :count).by(1)

      user = WTForum::User.find(user.id)
      user.username.should == "wtforum_test_user"
      user.email.should == "wtforum_test_user@example.com"

      user.update_attributes! username: "wtforum_test_user_2", email: "wtforum_test_user_2@example.com"

      user = WTForum::User.find_by_username("wtforum_test_user_2")
      user.username.should == "wtforum_test_user_2"
      user.email.should == "wtforum_test_user_2@example.com"

    ensure
      lambda {
        user.destroy
      }.should change(WTForum::User, :count).by(-1)
    end
  end

  it "raises an exception when a user is not found" do
    lambda {
      WTForum::User.find(0)
    }.should raise_exception(WTForum::User::NotFound)
  end
end
