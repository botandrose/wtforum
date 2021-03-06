# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wtforum/version'

Gem::Specification.new do |spec|
  spec.name          = "wtforum"
  spec.version       = WTForum::VERSION
  spec.authors       = ["Micah Geisel"]
  spec.email         = ["micah@botandrose.com"]
  spec.description   = %q{Ruby library that wraps Website Toolbox's forum API.}
  spec.summary       = %q{Ruby library that wraps Website Toolbox's forum API.}
  spec.homepage      = "https://github.com/botandrose/wtforum"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "mechanize"
  spec.add_dependency "nokogiri"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "debugger"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
end
