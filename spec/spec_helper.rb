require 'coveralls'
Coveralls.wear!

require 'bundler/setup'
Bundler.setup

require 'yandex_money/api'
require 'vcr'

IGNORED = %w(
  ./spec/support/constants.example.rb
)
RSpec.configure do |config|
  (Dir["./spec/support/**/*.rb"] - IGNORED).each {|f| require f}
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.filter_sensitive_data('<ACCESS_TOKEN>') { ACCESS_TOKEN }
  c.filter_sensitive_data('<CLIENT_ID>') { CLIENT_ID }
  c.filter_sensitive_data('<INSTANCE_ID>') { INSTANCE_ID }
  c.filter_sensitive_data('<WALLET_NUMBER>') { WALLET_NUMBER }
  c.filter_sensitive_data('<OPERATION_ID>') { OPERATION_ID }
end

