# encoding: utf-8

require "spec_helper"

describe WTForum::User do
  it "can CRUD users" do
    begin
      user = nil

      lambda {
        user = WTForum::User.create username: "wtforum_test_user", email: "wtforum_test_user@example.com", gender: "Male", about: "I am a test user"
      }.should change(WTForum::User, :count).by(1)

      user = WTForum::User.find(user.id)
      user.username.should == "wtforum_test_user"
      user.email.should == "wtforum_test_user@example.com"
      user.gender.should == "Male"
      user.about.should == "I am a test user"

      user.update_attributes! username: "wtforum_test_user_2", email: "wtforum_test_user_2@example.com", gender: "Female", about: "I am an updated test user"

      user = WTForum::User.find_by_username("wtforum_test_user_2")
      user.username.should == "wtforum_test_user_2"
      user.email.should == "wtforum_test_user_2@example.com"
      user.gender.should == "Female"
      user.about.should == "I am an updated test user"

    ensure
      lambda {
        WTForum::User.destroy(user.id) rescue nil or
          WTForum::User.find_by_username("wtforum_test_user").destroy rescue nil or
          WTForum::User.find_by_username("wtforum_test_user_2").destroy rescue nil
      }.should change(WTForum::User, :count).by(-1)
    end
  end

  it "raises an exception when a user is not found" do
    lambda {
      WTForum::User.find(0)
    }.should raise_exception(WTForum::User::NotFound)
  end
end
