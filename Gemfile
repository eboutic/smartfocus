
source "http://rubygems.org"

gemspec

group :development, :test do
  gem 'guard'
  gem 'redcarpet' # Required by Yard
  gem 'yard'
end

group :test do
  gem 'coveralls', require: false
  gem 'guard-rspec'
  gem 'rake' # Required by Travis CI
  gem 'rspec'
  gem 'tzinfo'
  gem 'vcr'
  gem 'webmock', '< 1.12'
end