# encoding: utf-8

require "wtforum"

begin
  require "./spec/support/credentials.rb"
rescue LoadError
  puts %(
    To run the tests, you must create a login credentials file at spec/support/credentials.rb. Example:

    WTForum.domain = "forum.example.com"
    WTForum.api_key = "TEgPYR4Zapz"
    WTForum.admin_username = "__admin_api_dont_delete__"
    WTForum.admin_password = "s0m3p4ssw0rd"
  )
  exit
end

