require 'coveralls'
Coveralls.wear!

require 'bundler/setup'
Bundler.setup

require 'yandex_money/api'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
end

IGNORED = %w(
  ./spec/support/constants.example.rb
)
RSpec.configure do |config|
  (Dir["./spec/support/**/*.rb"] - IGNORED).each {|f| require f}
end
