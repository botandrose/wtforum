require "spec_helper"

describe WTForum::User, vcr: true do
  let(:wtforum) { test_wtforum }

  it "can CRUD users" do
    begin
      user = nil

      lambda {
        user = wtforum.create_user(
          username: "wtforum_test_user",
          email: "wtforum_test_user@example.com",
          name: "Test User",
          gender: "Male",
          location: "Portland, Oregon, USA",
          about: "I am a test user")
      }.should change { wtforum.count_users }.by(1)

      user = wtforum.find_user(user.id)
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

      user = wtforum.find_user_by_username("wtforum_test_user_2")
      user.username.should == "wtforum_test_user_2"
      user.email.should == "wtforum_test_user_2@example.com"
      user.name.should == "Test User 2"
      user.gender.should == "Female"
      user.location.should == "Vancouver, BC, Canada"
      user.about.should == "I am an updated test user"

    ensure
      lambda {
        wtforum.destroy_user(user.id) rescue nil or
          wtforum.find_user_by_username("wtforum_test_user").destroy rescue nil or
          wtforum.find_user_by_username("wtforum_test_user_2").destroy rescue nil
      }.should change { wtforum.count_users }.by(-1)
    end
  end

  it "raises an exception when a user is not found" do
    lambda {
      wtforum.find_user(0)
    }.should raise_exception(WTForum::User::NotFound)
  end

  it "raises an exception when a username is already taken and the retry option is false" do
    begin
      wtforum.create_user(
        username: "wtforum_test_user",
        email: "wtforum_test_user@example.com",
        name: "Test User",
        gender: "Male",
        location: "Portland, Oregon, USA",
        about: "I am a test user")
      lambda {
        wtforum.create_user(
          username: "wtforum_test_user",
          email: "some_other_wtforum_test_user@example.com",
          name: "Some Other Test User",
          gender: "Male",
          location: "Portland, Oregon, USA",
          about: "I am another test user",
          retry: false)
      }.should raise_exception(WTForum::User::UsernameAlreadyTaken)

    ensure
      wtforum.find_user_by_username("wtforum_test_user").destroy rescue nil
    end
  end

  it "retries with successive usernames if one is already taken" do
    begin
      wtforum.create_user(
        username: "wtforum_test_user",
        email: "wtforum_test_user@example.com",
        name: "Test User",
        gender: "Male",
        location: "Portland, Oregon, USA",
        about: "I am a test user")

      wtforum_user = wtforum.create_user(
        username: "wtforum_test_user",
        email: "some_other_wtforum_test_user@example.com",
        name: "Some Other Test User",
        gender: "Male",
        location: "Portland, Oregon, USA",
        about: "I am another test user")

      wtforum_user.username.should == "wtforum_test_user1"

    ensure
      wtforum.find_user_by_username("wtforum_test_user").destroy rescue nil
      wtforum.find_user_by_username("wtforum_test_user1").destroy rescue nil
    end
  end

  it "returns existing user if one already exists" do
    begin
      wtforum.create_user(
        username: "wtforum_test_user",
        email: "wtforum_test_user@example.com",
        name: "Test User",
        gender: "Male",
        location: "Portland, Oregon, USA",
        about: "I am a test user")

      wtforum_user = wtforum.create_user(
        username: "wtforum_test_user",
        email: "wtforum_test_user@example.com",
        name: "Test User",
        gender: "Male",
        location: "Portland, Oregon, USA",
        about: "I am a test user")

      wtforum_user.username.should == "wtforum_test_user"

    ensure
      wtforum.find_user_by_username("wtforum_test_user").destroy rescue nil
    end
  end
end

