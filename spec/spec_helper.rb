require 'rubygems'

require 'coveralls'
Coveralls.wear!

require 'smartfocus'
require 'rspec'
require 'vcr'
require 'webmock/rspec'

ENV["GUARD_ENV"] = 'test'

Dir["#{File.expand_path('..', __FILE__)}/support/**/*.rb"].each { |f| require f }

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cache/vcr'
  c.allow_http_connections_when_no_cassette = true
  c.hook_into :webmock
end

RSpec.configure do |config|
  config.color_enabled = true
  config.order = :random
  config.filter_run focus: ENV['CI'] != 'true'
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

end