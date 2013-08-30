require "wtforum"
require "vcr"

VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

begin
  require "./spec/support/credentials.rb"
rescue LoadError
  puts %(
    To run the tests, you must create a login credentials file at spec/support/credentials.rb. Example:

    WTFORUM_DOMAIN = "forum.example.com"
    WTFORUM_API_KEY = "TEgPYR4Zapz"
    WTFORUM_ADMIN_USERNAME = "__admin_api_dont_delete__"
    WTFORUM_ADMIN_PASSWORD = "s0m3p4ssw0rd"
  )
  exit
end

def test_wtforum
  @test_wtforum ||= WTForum.new domain: WTFORUM_DOMAIN,
    api_key: WTFORUM_API_KEY,
    admin_username: WTFORUM_ADMIN_USERNAME,
    admin_password: WTFORUM_ADMIN_PASSWORD
end

