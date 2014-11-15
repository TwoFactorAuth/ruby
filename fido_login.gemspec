$:.push File.expand_path("../lib", __FILE__)

require "fido_login/version"

Gem::Specification.new do |s|
  s.name        = "fido_login"
  s.version     = FidoLogin::VERSION
  s.authors     = ["Peter Harkins"]
  s.email       = ["ph@push.cx"]
  s.homepage    = "https://www.fidologin.com"
  s.summary     = "Support FIDO alliance universal two-factor authentication"
  s.description = "FidoLogin makes it easy to set up two-factor authentication for your users, whether through Devise or your custom Rails or Ruby authentication."
  s.licenses    = ["AGPL-3.0", "Commercial"]

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.7"

  s.add_development_dependency "sqlite3"
end
