# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)
require 'smartfocus/version'

Gem::Specification.new do |s|
  s.name        = 'smartfocus'
  s.summary     = "Smartfocus"
  s.description = "REST API wrapper interacting with Smartfocus (ex Emailvision)"
  s.version     = Smartfocus::Version
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.license     = 'MIT'

  s.files       = Dir["lib/**/*"]
  s.require_path = 'lib'

  s.authors     = 'eboutic.ch'
  s.email       = 'tech@eboutic.ch'
  s.homepage    = 'https://github.com/eboutic/smartfocus'
  
  s.add_dependency("httparty", "~> 0.12.0")
  s.add_dependency("crack", "~> 0.4.0")
  s.add_dependency("builder", ">= 3.0")
  s.add_dependency("activesupport", ">= 3.0", "~> 4.0.0")
end