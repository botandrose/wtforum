require "spec_helper"

describe WTForum::User do
  it "can CRUD users" do
    begin
      user = nil

      lambda {
        user = WTForum::User.create(
          username: "wtforum_test_user",
          email: "wtforum_test_user@example.com",
          name: "Test User",
          gender: "Male",
          location: "Portland, Oregon, USA",
          about: "I am a test user")
      }.should change(WTForum::User, :count).by(1)

      user = WTForum::User.find(user.id)
      user.username.should == "wtforum_test_user"
      user.email.should == "wtforum_test_user@example.com"
      user.name.should == "Test User"
      user.gender.should == "Male"
      user.location.should == "Portland, Oregon, USA"
      user.about.should == "I am a test user"

      user.update_attributes!(
        username: "wtforum_test_user_2",
        email: "wtforum_test_user_2@example.com",
        name: "Test User 2",
        gender: "Female",
        location: "Vancouver, BC, Canada",
        about: "I am an updated test user")

      user = WTForum::User.find_by_username("wtforum_test_user_2")
      user.username.should == "wtforum_test_user_2"
      user.email.should == "wtforum_test_user_2@example.com"
      user.name.should == "Test User 2"
      user.gender.should == "Female"
      user.location.should == "Vancouver, BC, Canada"
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

