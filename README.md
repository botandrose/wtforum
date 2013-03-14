# WTForum

Ruby library that wraps Website Toolbox's Forum API.

Useful for folks looking to embed the forum into their site, while maintaining
a user-facing appearance of a single user account.

## Installation

Add this line to your application's Gemfile:

    gem 'wtforum'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wtforum

## Features

WTForum has the following features:

### CRUD user accounts

    # Modeled after ActiveRecord API

    # Create
    user = WTForum::User.create username: "wtforum_test_user", email: "wtforum_test_user@example.com"

    # Read
    WTForum::User.count
    user = WTForum::User.find(user.id)
    user = WTForum::User.find_by_username(user.username)

    # Update
    user.update_attributes! username: "wtforum_test_user_2", email: "wtforum_test_user_2@example.com"

    # Destroy
    WTForum::User.destroy(user.id)
    user.destroy

### Log in your user via their Single Sign On (SSO) API

    session = WTForum::Session.create(user.id)
    session.token # => REiB6U5SkxB

## Configuration

Before using WTForum, you need to give it administrator credentials. It
needs four pieces of information:

1. Where the forum is hosted.
2. The API key that Website Toolbox provides.
3. Username of an admin account.
4. Password for said admin account.

Example Rails config:

    # config/initializers/wtforum_credentials.rb
    WTForum.domain = "forum.example.com"
    WTForum.api_key = "TEgPYR4Zapz"
    WTForum.admin_username = "__admin_api_dont_delete__"
    WTForum.admin_password = "s0m3p4ssw0rd"

## Why do we need to specify an admin user account in the credentials?

Unfortunately, Website Toolbox's Forum API is missing some functionality.
Specifically, you can only create a new forum user account. Need to read,
update, or delete an existing user via the API? You're out of luck! As a
workaround, this library uses an admin account and Mechanize to sign into
the website and manually fill out forms and screenscrape the results. I hope
that the API's breadth of functionality improves in the future.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
