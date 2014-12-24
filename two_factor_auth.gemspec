$:.push File.expand_path("../lib", __FILE__)

require "two_factor_auth/version"

Gem::Specification.new do |s|
  s.name        = "two_factor_auth"
  s.version     = TwoFactorAuth::VERSION
  s.authors     = ["Peter Harkins"]
  s.email       = ["ph@push.cx"]
  s.homepage    = "https://www.twofactorauth.io/rails"
  s.summary     = "Support FIDO alliance universal two-factor authentication"
  s.description = "TwoFactorAuth makes it easy to set up two-factor authentication for your users, whether through Devise or your custom Rails or Ruby authentication."
  s.licenses    = ["AGPL-3.0", "Commercial"]

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'activemodel', '~> 4.0', '<= 4.2'
  s.add_dependency 'adamantium', '~> 0.2'
  s.add_dependency 'virtus', '~> 1.0'

  s.add_development_dependency 'rails', '~> 4.0', '<= 4.2'
  s.add_development_dependency "devise", '~> 3.3', '< 4'
  s.add_development_dependency "minitest-rails", '~> 2.1'
  s.add_development_dependency "pry", '~> 0.10'
  s.add_development_dependency "sqlite3", '~> 1.3', '< 2'
end
